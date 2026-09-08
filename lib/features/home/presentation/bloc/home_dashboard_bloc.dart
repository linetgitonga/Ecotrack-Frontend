import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/error_messages.dart';
import '../../../../data/remote/api/tierb_api.dart';
import '../../../../domain/entities/alert.dart';
import '../../../../domain/entities/device.dart';

part 'home_dashboard_event.dart';
part 'home_dashboard_state.dart';

@injectable
class HomeDashboardBloc extends Bloc<HomeDashboardEvent, HomeDashboardState> {
  HomeDashboardBloc(this._api) : super(const HomeDashboardState()) {
    on<DashboardSubscribed>(_onSubscribed, transformer: restartable());
    on<DashboardRefreshed>(_onRefresh, transformer: droppable());
    on<DashboardLiveTick>(_onTick, transformer: droppable());
    on<DashboardModeSelected>(_onMode, transformer: droppable());
    on<DashboardQuickToggled>(_onToggle);
  }

  final TierBApi _api;
  String _siteId = '';
  Timer? _timer;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onSubscribed(
    DashboardSubscribed e,
    Emitter<HomeDashboardState> emit,
  ) async {
    _siteId = e.siteId;
    emit(state.copyWith(status: DashboardStatus.loading));
    await _loadAll(emit);
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const DashboardLiveTick()),
    );
  }

  Future<void> _onRefresh(
    DashboardRefreshed e,
    Emitter<HomeDashboardState> emit,
  ) => _loadAll(emit);

  Future<void> _onTick(
    DashboardLiveTick e,
    Emitter<HomeDashboardState> emit,
  ) async {
    final live = await _api.live(_siteId);
    final summary = await _api.summary(_siteId);
    if (live.isErr) return;
    emit(
      state.copyWith(
        quickDevices: _quick(live.valueOrNull!),
        usage: summary.valueOrNull ?? state.usage,
      ),
    );
  }

  Future<void> _onMode(
    DashboardModeSelected e,
    Emitter<HomeDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        modes: [
          for (final m in state.modes)
            EnergyMode(
              id: m.id,
              key: m.key,
              name: m.name,
              isActive: m.id == e.modeId,
            ),
        ],
      ),
    );
    final r = await _api.activateMode(e.modeId);
    if (r.isErr) {
      emit(state.copyWith(error: ErrorMessages.forFailure(r.failureOrNull!)));
      await _loadAll(emit);
    }
  }

  Future<void> _onToggle(
    DashboardQuickToggled e,
    Emitter<HomeDashboardState> emit,
  ) async {
    final device = state.quickDevices.firstWhere((d) => d.id == e.deviceId);
    final next = !device.relayState;
    emit(
      state.copyWith(
        quickDevices: [
          for (final d in state.quickDevices)
            d.id == e.deviceId ? d.copyWith(relayState: next) : d,
        ],
      ),
    );
    final r = await _api.sendCommand(e.deviceId, on: next);
    if (r.isErr) {
      emit(
        state.copyWith(
          error: ErrorMessages.forFailure(r.failureOrNull!),
          quickDevices: [
            for (final d in state.quickDevices)
              d.id == e.deviceId ? d.copyWith(relayState: !next) : d,
          ],
        ),
      );
    }
  }

  Future<void> _loadAll(Emitter<HomeDashboardState> emit) async {
    final results = await Future.wait([
      _api.summary(_siteId),
      _api.live(_siteId),
      _api.costSummary(_siteId),
      _api.modes(_siteId),
      _api.alerts(_siteId),
    ]);

    final usage = (results[0] as dynamic).valueOrNull as LiveUsage?;
    final devices = (results[1] as dynamic).valueOrNull as List<Device>?;
    final cost = (results[2] as dynamic).valueOrNull as CostSummary?;
    final modes = (results[3] as dynamic).valueOrNull as List<EnergyMode>?;
    final alerts = (results[4] as dynamic).valueOrNull as List<AlertEvent>?;

    if (usage == null && devices == null && cost == null) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          error: 'Could not load your dashboard',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: DashboardStatus.loaded,
        usage: _withCost(usage, cost),
        cost: cost,
        modes: modes ?? state.modes,
        quickDevices: devices != null ? _quick(devices) : state.quickDevices,
        unreadAlerts:
            alerts?.where((a) => a.status == AlertStatus.open).length ?? 0,
        error: null,
      ),
    );
  }

  LiveUsage? _withCost(LiveUsage? u, CostSummary? c) {
    if (u == null) return null;
    return LiveUsage(
      liveWatts: u.liveWatts,
      todayKwh: u.todayKwh,
      todayKes: c?.today.asDouble ?? u.todayKes,
      isEstimated: u.isEstimated || (c?.isEstimated ?? false),
      dailyBudgetKwh: u.dailyBudgetKwh,
    );
  }

  List<Device> _quick(List<Device> all) =>
      all.where((d) => d.switchable).take(6).toList();
}
