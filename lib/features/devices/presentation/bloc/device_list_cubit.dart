import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/error_messages.dart';
import '../../../../data/remote/api/tierb_api.dart';
import '../../../../domain/entities/device.dart';

enum DeviceFilter { all, online, critical }

class DeviceListState extends Equatable {
  const DeviceListState({
    this.loading = true,
    this.devices = const [],
    this.filter = DeviceFilter.all,
    this.query = '',
    this.error,
    this.busyIds = const {},
  });

  final bool loading;
  final List<Device> devices;
  final DeviceFilter filter;
  final String query;
  final String? error;
  final Set<String> busyIds;

  List<Device> get visible {
    var list = devices;
    if (filter == DeviceFilter.online) {
      list = list.where((d) => d.reachable).toList();
    } else if (filter == DeviceFilter.critical) {
      list = list.where((d) => d.deviceClass == 'relay_module').toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((d) => d.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  /// visible devices grouped by room name (null → "Unassigned").
  Map<String, List<Device>> get byRoom {
    final map = <String, List<Device>>{};
    for (final d in visible) {
      (map[d.roomName ?? 'Unassigned'] ??= []).add(d);
    }
    return map;
  }

  DeviceListState copyWith({
    bool? loading,
    List<Device>? devices,
    DeviceFilter? filter,
    String? query,
    Object? error = _s,
    Set<String>? busyIds,
  }) => DeviceListState(
    loading: loading ?? this.loading,
    devices: devices ?? this.devices,
    filter: filter ?? this.filter,
    query: query ?? this.query,
    error: identical(error, _s) ? this.error : error as String?,
    busyIds: busyIds ?? this.busyIds,
  );

  static const _s = Object();

  @override
  List<Object?> get props => [loading, devices, filter, query, error, busyIds];
}

@injectable
class DeviceListCubit extends Cubit<DeviceListState> {
  DeviceListCubit(this._api) : super(const DeviceListState());
  final TierBApi _api;
  String _siteId = '';
  Timer? _timer;

  Future<void> subscribe(String siteId) async {
    _siteId = siteId;
    await load();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refreshLive());
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    final r = await _api.devices(_siteId);
    r.when(
      ok: (devices) => emit(state.copyWith(loading: false, devices: devices)),
      err: (f) => emit(
        state.copyWith(loading: false, error: ErrorMessages.forFailure(f)),
      ),
    );
  }

  Future<void> _refreshLive() async {
    final r = await _api.live(_siteId);
    if (r.isErr) return;
    final live = {for (final d in r.valueOrNull!) d.id: d};
    emit(
      state.copyWith(
        devices: [for (final d in state.devices) live[d.id]?.copyWith() ?? d],
      ),
    );
  }

  void setFilter(DeviceFilter f) => emit(state.copyWith(filter: f));
  void setQuery(String q) => emit(state.copyWith(query: q));

  Future<void> toggle(String deviceId) async {
    final device = state.devices.firstWhere((d) => d.id == deviceId);
    final next = !device.relayState;
    emit(
      state.copyWith(
        busyIds: {...state.busyIds, deviceId},
        devices: [
          for (final d in state.devices)
            d.id == deviceId ? d.copyWith(relayState: next) : d,
        ],
      ),
    );
    final r = await _api.sendCommand(deviceId, on: next);
    emit(
      state.copyWith(
        busyIds: state.busyIds.where((id) => id != deviceId).toSet(),
        devices: r.isErr
            ? [
                for (final d in state.devices)
                  d.id == deviceId ? d.copyWith(relayState: !next) : d,
              ]
            : state.devices,
        error: r.isErr ? ErrorMessages.forFailure(r.failureOrNull!) : null,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
