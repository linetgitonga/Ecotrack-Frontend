import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/remote/api/tierb_api.dart';
import '../../../../domain/entities/alert.dart';
import '../../../../domain/entities/site.dart';
import '../../../../domain/value_objects/money.dart';

/// One site as seen in the portfolio ("unit") table.
class UnitRow extends Equatable {
  const UnitRow({
    required this.site,
    required this.liveWatts,
    required this.todayKwh,
    required this.monthCost,
    required this.openAlerts,
    required this.estimated,
  });

  final Site site;
  final double liveWatts;
  final double todayKwh;
  final Money monthCost;
  final int openAlerts;
  final bool estimated;

  String get status => openAlerts > 0
      ? 'Attention'
      : site.isActive
          ? 'OK'
          : site.status;

  @override
  List<Object?> get props => [site.id, liveWatts, todayKwh, monthCost, openAlerts];
}

class PortfolioState extends Equatable {
  const PortfolioState({
    this.loading = true,
    this.units = const [],
    this.criticalAlerts = const [],
    this.error,
  });

  final bool loading;
  final List<UnitRow> units;
  final List<({String siteLabel, AlertEvent alert})> criticalAlerts;
  final String? error;

  int get unitCount => units.length;
  double get totalWatts => units.fold(0, (s, u) => s + u.liveWatts);
  double get totalTodayKwh => units.fold(0, (s, u) => s + u.todayKwh);
  Money get totalMonthCost =>
      units.fold(Money.zero, (s, u) => s + u.monthCost);
  int get totalOpenAlerts => units.fold(0, (s, u) => s + u.openAlerts);
  int get unitsNeedingAttention =>
      units.where((u) => u.openAlerts > 0 || !u.site.isActive).length;

  PortfolioState copyWith({
    bool? loading,
    List<UnitRow>? units,
    List<({String siteLabel, AlertEvent alert})>? criticalAlerts,
    Object? error = _s,
  }) =>
      PortfolioState(
        loading: loading ?? this.loading,
        units: units ?? this.units,
        criticalAlerts: criticalAlerts ?? this.criticalAlerts,
        error: identical(error, _s) ? this.error : error as String?,
      );

  static const _s = Object();

  @override
  List<Object?> get props => [loading, units, criticalAlerts, error];
}

/// Aggregates the signed-in owner's sites into a portfolio view. No dedicated
/// backend endpoint — fans out over the site list (Q1: multi-site owner, not a
/// separate persona).
@injectable
class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit(this._api) : super(const PortfolioState());
  final TierBApi _api;

  Future<void> load(List<Site> sites) async {
    emit(state.copyWith(loading: true, error: null));
    if (sites.isEmpty) {
      emit(const PortfolioState(loading: false));
      return;
    }

    final rows = <UnitRow>[];
    final critical = <({String siteLabel, AlertEvent alert})>[];

    for (final site in sites) {
      final results = await Future.wait([
        _api.summary(site.id),
        _api.costSummary(site.id),
        _api.alerts(site.id),
      ]);
      final summary = (results[0] as dynamic).valueOrNull as LiveUsage?;
      final cost = (results[1] as dynamic).valueOrNull as CostSummary?;
      final alerts =
          (results[2] as dynamic).valueOrNull as List<AlertEvent>? ?? const [];
      final open =
          alerts.where((a) => a.status == AlertStatus.open).toList();

      rows.add(UnitRow(
        site: site,
        liveWatts: summary?.liveWatts ?? 0,
        todayKwh: summary?.todayKwh ?? 0,
        monthCost: cost?.monthToDate ?? Money.zero,
        openAlerts: open.length,
        estimated: cost?.isEstimated ?? true,
      ));
      for (final a in open.where((a) => a.severity == AlertSeverity.critical)) {
        critical.add((siteLabel: site.label, alert: a));
      }
    }

    emit(PortfolioState(
      loading: false,
      units: rows,
      criticalAlerts: critical,
    ));
  }
}
