import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/error_messages.dart';
import '../../../../data/remote/api/tierb_api.dart';
import '../../../../domain/entities/alert.dart';

class AlertsState extends Equatable {
  const AlertsState({
    this.loading = true,
    this.alerts = const [],
    this.error,
    this.busyId,
  });

  final bool loading;
  final List<AlertEvent> alerts;
  final String? error;
  final String? busyId;

  List<AlertEvent> byStatus(AlertStatus s) =>
      alerts.where((a) => a.status == s).toList()
        ..sort((a, b) => b.openedAt.compareTo(a.openedAt));

  int get openCount => alerts.where((a) => a.status == AlertStatus.open).length;

  AlertsState copyWith({
    bool? loading,
    List<AlertEvent>? alerts,
    Object? error = _s,
    Object? busyId = _s,
  }) =>
      AlertsState(
        loading: loading ?? this.loading,
        alerts: alerts ?? this.alerts,
        error: identical(error, _s) ? this.error : error as String?,
        busyId: identical(busyId, _s) ? this.busyId : busyId as String?,
      );

  static const _s = Object();

  @override
  List<Object?> get props => [loading, alerts, error, busyId];
}

@injectable
class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit(this._api) : super(const AlertsState());
  final TierBApi _api;
  String _siteId = '';

  Future<void> load(String siteId) async {
    _siteId = siteId;
    emit(state.copyWith(loading: true, error: null));
    final r = await _api.alerts(_siteId);
    r.when(
      ok: (a) => emit(AlertsState(loading: false, alerts: a)),
      err: (f) => emit(state.copyWith(
        loading: false,
        error: ErrorMessages.forFailure(f),
      )),
    );
  }

  Future<void> acknowledge(String id) async {
    emit(state.copyWith(busyId: id));
    final r = await _api.acknowledgeAlert(id);
    if (r.isOk) {
      emit(state.copyWith(
        busyId: null,
        alerts: [
          for (final a in state.alerts)
            a.id == id
                ? AlertEvent(
                    id: a.id,
                    severity: a.severity,
                    title: a.title,
                    description: a.description,
                    openedAt: a.openedAt,
                    type: a.type,
                    closedAt: a.closedAt,
                    acknowledgedAt: DateTime.now(),
                  )
                : a,
        ],
      ));
    } else {
      emit(state.copyWith(
        busyId: null,
        error: ErrorMessages.forFailure(r.failureOrNull!),
      ));
    }
  }
}
