import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/result.dart';
import '../../../core/network/dio_factory.dart';
import '../../../domain/entities/alert.dart';
import '../../../domain/entities/device.dart';
import '../../../domain/value_objects/money.dart';
import 'api_client.dart';

/// Tier-B reads/writes for the tenant dashboard. Every call goes to the real
/// endpoint first; `MockInterceptor` fills in when it 404s (plan §1.4 A2).
@lazySingleton
class TierBApi {
  TierBApi(@Named(DioNames.cloud) this._client);
  final ApiClient _client;

  double _d(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

  // --- Devices -----------------------------------------------------
  Future<Result<List<Device>>> devices(String siteId) =>
      _client.get<List<Device>>(
        ApiPaths.devices,
        query: {'site_id': siteId},
        parse: (d) => ApiEnvelope.list(d).map(_device).toList(),
      );

  Future<Result<List<Device>>> live(String siteId) => _client.get<List<Device>>(
    ApiPaths.telemetryLive,
    query: {'site_id': siteId},
    parse: (d) {
      final obj = ApiEnvelope.object(d);
      final list = obj['devices'] is List
          ? (obj['devices'] as List).cast<Map<String, dynamic>>()
          : ApiEnvelope.list(d);
      return list.map(_device).toList();
    },
  );

  Future<Result<LiveUsage>> summary(String siteId) => _client.get<LiveUsage>(
    ApiPaths.telemetrySummary,
    query: {'site_id': siteId},
    parse: (d) {
      final t = ApiEnvelope.object(d);
      return LiveUsage(
        liveWatts: _d(t['live_watts']),
        todayKwh: _d(t['today_kwh']),
        todayKes: 0,
        isEstimated: t['today_kwh_estimated'] == true,
        dailyBudgetKwh: t['daily_budget_kwh'] == null
            ? null
            : _d(t['daily_budget_kwh']),
      );
    },
  );

  Future<Result<Unit>> openPairing(String hubId) async {
    final r = await _client.post<Object?>(
      ApiPaths.hubPairingMode(hubId),
      body: const {'ttl_s': 120},
      parse: (d) => d,
    );
    return r.map((_) => Unit.value);
  }

  Future<Result<List<CommissioningEntry>>> commissioning() =>
      _client.get<List<CommissioningEntry>>(
        ApiPaths.devicesCommissioning,
        parse: (d) => ApiEnvelope.list(d)
            .map((e) => CommissioningEntry(
                  deviceId: e['device_id']?.toString() ?? '',
                  name: e['friendly_name']?.toString() ?? 'New device',
                  status: e['commissioning_status']?.toString() ?? 'discovered',
                  error: e['commissioning_error']?.toString(),
                ))
            .toList(),
      );

  Future<Result<List<Map<String, dynamic>>>> hubs() =>
      _client.get<List<Map<String, dynamic>>>(
        ApiPaths.hubs,
        parse: ApiEnvelope.list,
      );

  Future<Result<Device>> device(String deviceId) => _client.get<Device>(
        ApiPaths.device(deviceId),
        parse: (d) => _device(ApiEnvelope.object(d)),
      );

  Future<Result<List<double>>> deviceSeries(String deviceId) =>
      _client.get<List<double>>(
        ApiPaths.telemetrySeries,
        query: {'device_id': deviceId, 'resolution': 'hourly', 'from': '24h'},
        parse: (d) {
          final obj = ApiEnvelope.object(d);
          final pts = obj['points'] is List ? (obj['points'] as List) : const [];
          return pts.map((p) => _d((p as Map)['value'])).toList();
        },
      );

  Future<Result<Unit>> sendCommand(
    String deviceId, {
    required bool on,
    String? idempotencyKey,
  }) async {
    final r = await _client.post<Object?>(
      ApiPaths.deviceCommands(deviceId),
      body: {'action': 'switch', 'state': on ? 'on' : 'off', 'ttl_s': 300},
      idempotencyKey: idempotencyKey,
      parse: (d) => d,
    );
    return r.map((_) => Unit.value);
  }

  // --- Cost ------------------------------------------------------
  Future<Result<CostSummary>> costSummary(String siteId) =>
      _client.get<CostSummary>(
        ApiPaths.costsSummary,
        query: {'site_id': siteId, 'period': 'monthly'},
        parse: (d) {
          final c = ApiEnvelope.object(d);
          return CostSummary(
            monthToDate: Money.parse(
              '${c['kes_accumulated'] ?? '0'}',
              isEstimated: c['is_estimated'] == true,
            ),
            today: Money.parse(
              '${c['today_kes'] ?? '0'}',
              isEstimated: c['is_estimated'] == true,
            ),
            kwhAccumulated: _d(c['kwh_accumulated']),
            marginalRate: Money.parse('${c['marginal_rate'] ?? '0'}'),
            bandPosition: c['band_position']?.toString(),
            isEstimated: c['is_estimated'] == true,
          );
        },
      );

  Future<Result<List<CostSlice>>> costBreakdown(String siteId) =>
      _client.get<List<CostSlice>>(
        ApiPaths.costsBreakdown,
        query: {'site_id': siteId, 'period': 'monthly'},
        parse: (d) {
          final obj = ApiEnvelope.object(d);
          final list = obj['appliances'] is List
              ? (obj['appliances'] as List).cast<Map<String, dynamic>>()
              : ApiEnvelope.list(d);
          return list
              .map(
                (e) => CostSlice(
                  label: e['label']?.toString() ?? '—',
                  amount: Money.parse('${e['kes'] ?? '0'}', isEstimated: true),
                  share: _d(e['share']),
                ),
              )
              .toList();
        },
      );

  Future<Result<List<double>>> costSeries(String siteId) =>
      _client.get<List<double>>(
        ApiPaths.costsSeries,
        query: {'site_id': siteId, 'from': '7d'},
        parse: (d) {
          final obj = ApiEnvelope.object(d);
          final pts = obj['points'] is List
              ? (obj['points'] as List)
              : (d is List ? d : const []);
          return pts.map((p) => _d((p as Map)['value'])).toList();
        },
      );

  Future<Result<List<Recommendation>>> insights(String siteId) =>
      _client.get<List<Recommendation>>(
        ApiPaths.insights,
        query: {'site_id': siteId},
        parse: (d) {
          final obj = ApiEnvelope.object(d);
          final list = obj['recommendations'] is List
              ? (obj['recommendations'] as List).cast<Map<String, dynamic>>()
              : ApiEnvelope.list(d);
          return list
              .map((e) => Recommendation(
                    id: e['id']?.toString() ?? '',
                    title: e['title']?.toString() ?? '',
                    detail: e['detail']?.toString() ?? '',
                    estimatedSaving: e['estimated_saving_kes'] == null
                        ? null
                        : Money.parse('${e['estimated_saving_kes']}'),
                  ))
              .toList();
        },
      );

  // --- Modes -----------------------------------------------------
  Future<Result<List<EnergyMode>>> modes(String siteId) =>
      _client.get<List<EnergyMode>>(
        ApiPaths.siteModes(siteId),
        parse: (d) => ApiEnvelope.list(d)
            .map(
              (e) => EnergyMode(
                id: e['mode_id']?.toString() ?? '',
                key: e['key']?.toString() ?? '',
                name:
                    e['display_name']?.toString() ?? e['key']?.toString() ?? '',
                isActive: e['is_active'] == true,
              ),
            )
            .toList(),
      );

  Future<Result<Unit>> activateMode(String modeId) async {
    final r = await _client.post<Object?>(
      ApiPaths.modeActivate(modeId),
      body: const {},
      idempotencyKey: 'mode-$modeId-${DateTime.now().millisecondsSinceEpoch}',
      parse: (d) => d,
    );
    return r.map((_) => Unit.value);
  }

  // --- Automation ---------------------------------------------
  Future<Result<List<AutomationItem>>> rules(String siteId) =>
      _client.get<List<AutomationItem>>(
        ApiPaths.siteRules(siteId),
        parse: (d) => ApiEnvelope.list(d)
            .map((e) => AutomationItem(
                  id: e['rule_id']?.toString() ?? '',
                  name: e['name']?.toString() ?? 'Rule',
                  enabled: e['enabled'] != false,
                  summary: _ruleSummary(e),
                ))
            .toList(),
      );

  Future<Result<List<AutomationItem>>> schedules(String siteId) =>
      _client.get<List<AutomationItem>>(
        ApiPaths.siteSchedules(siteId),
        parse: (d) => ApiEnvelope.list(d)
            .map((e) => AutomationItem(
                  id: e['schedule_entry_id']?.toString() ?? '',
                  name: '${e['action']} · ${e['start_local']}–${e['end_local']}',
                  enabled: e['enabled'] != false,
                  summary: _daysSummary(e['days_mask']),
                ))
            .toList(),
      );

  Future<Result<List<BudgetItem>>> budgets(String siteId) =>
      _client.get<List<BudgetItem>>(
        ApiPaths.siteBudgets(siteId),
        parse: (d) => ApiEnvelope.list(d)
            .map((e) => BudgetItem(
                  id: e['budget_id']?.toString() ?? '',
                  period: e['period']?.toString() ?? 'weekly',
                  limit: Money.parse('${e['limit_kes'] ?? '0'}'),
                  spent: Money.parse('${e['spent_kes'] ?? '0'}'),
                  warnAtPct: (e['warn_at_pct'] as num?)?.toInt() ?? 80,
                  enabled: e['enabled'] != false,
                ))
            .toList(),
      );

  static String _ruleSummary(Map<String, dynamic> e) {
    final t = e['trigger'];
    if (t is Map && t['type'] == 'mode_enter') return 'When entering ${t['mode_key']} mode';
    if (t is Map && t['type'] == 'power') return 'On sustained high power';
    if (t is Map && t['type'] == 'schedule') return 'On a schedule';
    return 'Automation rule';
  }

  static String _daysSummary(Object? mask) {
    final m = (mask as num?)?.toInt() ?? 0;
    if (m == 127) return 'Every day';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final on = <String>[];
    for (var i = 0; i < 7; i++) {
      if (m & (1 << i) != 0) on.add(names[i]);
    }
    return on.join(', ');
  }

  // --- Alerts ------------------------------------------------
  Future<Result<List<AlertEvent>>> alerts(String siteId) =>
      _client.get<List<AlertEvent>>(
        ApiPaths.alerts,
        query: {'site_id': siteId},
        parse: (d) => ApiEnvelope.list(d).map(_alert).toList(),
      );

  Future<Result<Unit>> acknowledgeAlert(String id) async {
    final r = await _client.post<Object?>(
      ApiPaths.alertAcknowledge(id),
      body: const {},
      parse: (d) => d,
    );
    return r.map((_) => Unit.value);
  }

  // --- mapping -----------------------------------------------
  Device _device(Map<String, dynamic> e) => Device(
    id: e['device_id']?.toString() ?? '',
    name: e['friendly_name']?.toString() ?? 'Device',
    deviceClass: e['device_class']?.toString() ?? 'smart_plug',
    relayState: e['relay_state'] == true,
    reachable: e['reachable'] != false,
    roomId: e['room_id']?.toString(),
    watts: _d(e['watts']),
    volts: e['volts'] == null ? null : _d(e['volts']),
    amps: e['amps'] == null ? null : _d(e['amps']),
    lastSeenAt: DateTime.tryParse(e['last_seen_at']?.toString() ?? ''),
    switchable: e['device_class'] != 'sensor' && e['device_class'] != 'ct_main',
  );

  AlertEvent _alert(Map<String, dynamic> e) => AlertEvent(
    id: e['alert_event_id']?.toString() ?? '',
    severity: AlertEvent.severityFromApi(e['severity']?.toString() ?? 'info'),
    title: e['title']?.toString() ?? 'Alert',
    description: e['description']?.toString() ?? '',
    openedAt:
        DateTime.tryParse(e['opened_at']?.toString() ?? '') ?? DateTime.now(),
    type: e['alert_type']?.toString(),
    closedAt: DateTime.tryParse(e['closed_at']?.toString() ?? ''),
    acknowledgedAt: DateTime.tryParse(e['acknowledged_at']?.toString() ?? ''),
  );
}

class CostSummary extends Equatable {
  const CostSummary({
    required this.monthToDate,
    required this.today,
    required this.kwhAccumulated,
    required this.marginalRate,
    required this.isEstimated,
    this.bandPosition,
  });
  final Money monthToDate;
  final Money today;
  final double kwhAccumulated;
  final Money marginalRate;
  final bool isEstimated;
  final String? bandPosition;

  @override
  List<Object?> get props => [
    monthToDate,
    today,
    kwhAccumulated,
    marginalRate,
    isEstimated,
  ];
}

class CostSlice extends Equatable {
  const CostSlice({
    required this.label,
    required this.amount,
    required this.share,
  });
  final String label;
  final Money amount;
  final double share;

  @override
  List<Object?> get props => [label, amount, share];
}

class Recommendation extends Equatable {
  const Recommendation({
    required this.id,
    required this.title,
    required this.detail,
    this.estimatedSaving,
  });
  final String id;
  final String title;
  final String detail;
  final Money? estimatedSaving;

  @override
  List<Object?> get props => [id, title, detail];
}

class AutomationItem extends Equatable {
  const AutomationItem({
    required this.id,
    required this.name,
    required this.enabled,
    required this.summary,
  });
  final String id;
  final String name;
  final bool enabled;
  final String summary;

  @override
  List<Object?> get props => [id, name, enabled, summary];
}

class CommissioningEntry extends Equatable {
  const CommissioningEntry({
    required this.deviceId,
    required this.name,
    required this.status,
    this.error,
  });
  final String deviceId;
  final String name;
  final String status; // discovered|interviewing|joined|configured|failed
  final String? error;

  bool get isDone => status == 'configured';
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [deviceId, status];
}

class BudgetItem extends Equatable {
  const BudgetItem({
    required this.id,
    required this.period,
    required this.limit,
    required this.spent,
    required this.warnAtPct,
    required this.enabled,
  });
  final String id;
  final String period;
  final Money limit;
  final Money spent;
  final int warnAtPct;
  final bool enabled;

  double get progress =>
      limit.micros == 0 ? 0 : (spent.micros / limit.micros).clamp(0, 1);

  @override
  List<Object?> get props => [id, period, limit, spent, enabled];
}
