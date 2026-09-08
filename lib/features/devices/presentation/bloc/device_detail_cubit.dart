import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/error_messages.dart';
import '../../../../data/remote/api/tierb_api.dart';
import '../../../../domain/entities/device.dart';

class DeviceDetailState extends Equatable {
  const DeviceDetailState({
    this.loading = true,
    this.device,
    this.series = const [],
    this.busy = false,
    this.error,
  });

  final bool loading;
  final Device? device;
  final List<double> series;
  final bool busy;
  final String? error;

  DeviceDetailState copyWith({
    bool? loading,
    Device? device,
    List<double>? series,
    bool? busy,
    Object? error = _s,
  }) =>
      DeviceDetailState(
        loading: loading ?? this.loading,
        device: device ?? this.device,
        series: series ?? this.series,
        busy: busy ?? this.busy,
        error: identical(error, _s) ? this.error : error as String?,
      );

  static const _s = Object();

  @override
  List<Object?> get props => [loading, device, series, busy, error];
}

@injectable
class DeviceDetailCubit extends Cubit<DeviceDetailState> {
  DeviceDetailCubit(this._api) : super(const DeviceDetailState());
  final TierBApi _api;
  String _id = '';
  Timer? _timer;

  Future<void> load(String deviceId) async {
    _id = deviceId;
    emit(state.copyWith(loading: true, error: null));
    final d = await _api.device(deviceId);
    final s = await _api.deviceSeries(deviceId);
    d.when(
      ok: (device) => emit(state.copyWith(
        loading: false,
        device: device,
        series: s.valueOrNull ?? const [],
      )),
      err: (f) => emit(state.copyWith(
        loading: false,
        error: ErrorMessages.forFailure(f),
      )),
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _refreshLive());
  }

  Future<void> _refreshLive() async {
    final r = await _api.live('');
    if (r.isErr) return;
    for (final d in r.valueOrNull!) {
      if (d.id == _id) {
        emit(state.copyWith(device: state.device?.copyWith(
          relayState: d.relayState,
          watts: d.watts,
          reachable: d.reachable,
        )));
      }
    }
  }

  Future<void> toggle() async {
    final device = state.device;
    if (device == null) return;
    final next = !device.relayState;
    emit(state.copyWith(
      busy: true,
      device: device.copyWith(relayState: next),
    ));
    final r = await _api.sendCommand(device.id, on: next);
    emit(state.copyWith(
      busy: false,
      device: r.isErr ? device.copyWith(relayState: !next) : null,
      error: r.isErr ? ErrorMessages.forFailure(r.failureOrNull!) : null,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
