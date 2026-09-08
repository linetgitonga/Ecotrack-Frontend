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
