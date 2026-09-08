import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/error_messages.dart';
import '../../../../data/repositories/device_repository.dart';
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
    this.queuedIds = const {},
  });

  final bool loading;
  final List<Device> devices;
  final DeviceFilter filter;
  final String query;
  final String? error;
  final Set<String> busyIds;

  /// Devices whose last command was queued offline.
  final Set<String> queuedIds;

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
    Set<String>? queuedIds,
  }) => DeviceListState(
    loading: loading ?? this.loading,
    devices: devices ?? this.devices,
    filter: filter ?? this.filter,
    query: query ?? this.query,
    error: identical(error, _s) ? this.error : error as String?,
    busyIds: busyIds ?? this.busyIds,
    queuedIds: queuedIds ?? this.queuedIds,
  );

  static const _s = Object();

  @override
  List<Object?> get props => [
    loading,
    devices,
    filter,
    query,
    error,
    busyIds,
    queuedIds,
  ];
}

@injectable
class DeviceListCubit extends Cubit<DeviceListState> {
  DeviceListCubit(this._repo) : super(const DeviceListState());
  final DeviceRepository _repo;
  String _siteId = '';
  StreamSubscription<List<Device>>? _sub;
  Timer? _timer;

  Future<void> subscribe(String siteId) async {
    _siteId = siteId;
    _sub?.cancel();
    _sub = _repo.watchDevices(siteId).listen((devices) {
      emit(state.copyWith(loading: false, devices: devices));
    });
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _repo.refreshLive(_siteId),
    );
  }

  Future<void> load() => _repo.refresh(_siteId);

  void setFilter(DeviceFilter f) => emit(state.copyWith(filter: f));
  void setQuery(String q) => emit(state.copyWith(query: q));

  Future<void> toggle(String deviceId) async {
    final device = state.devices.firstWhere((d) => d.id == deviceId);
    emit(state.copyWith(busyIds: {...state.busyIds, deviceId}));
    final r = await _repo.setPower(deviceId, !device.relayState);
    emit(
      state.copyWith(
        busyIds: state.busyIds.where((id) => id != deviceId).toSet(),
        queuedIds: r.valueOrNull == CommandOutcome.queued
            ? {...state.queuedIds, deviceId}
            : state.queuedIds.where((id) => id != deviceId).toSet(),
        error: r.isErr ? ErrorMessages.forFailure(r.failureOrNull!) : null,
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _timer?.cancel();
    return super.close();
  }
}
