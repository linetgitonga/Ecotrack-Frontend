import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/connectivity/connection_manager.dart';
import '../../../../core/connectivity/connection_state.dart';

sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();
  @override
  List<Object?> get props => [];
}

class _ConnChanged extends ConnectivityEvent {
  const _ConnChanged(this.connection);
  final EcoConnection connection;
  @override
  List<Object?> get props => [connection];
}

/// Manual re-probe (pull-to-refresh, "retry" on the offline banner).
class ConnectivityProbeRequested extends ConnectivityEvent {
  const ConnectivityProbeRequested();
}

/// Change the device-side transport preference (auto / lan_only / cloud_only).
class TransportPreferenceChanged extends ConnectivityEvent {
  const TransportPreferenceChanged(this.preference);
  final String preference;
  @override
  List<Object?> get props => [preference];
}

class ConnectivityState extends Equatable {
  const ConnectivityState(this.connection);
  final EcoConnection connection;

  ConnectionMode get mode => connection.mode;

  @override
  List<Object?> get props => [connection];
}

@lazySingleton
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc(this._manager) : super(ConnectivityState(_manager.current)) {
    on<_ConnChanged>((e, emit) => emit(ConnectivityState(e.connection)));
    on<ConnectivityProbeRequested>((_, _) => _manager.refresh());
    on<TransportPreferenceChanged>(_onPreference);

    _sub = _manager.stream.listen((c) => add(_ConnChanged(c)));
  }

  final ConnectionManager _manager;
  late final StreamSubscription<EcoConnection> _sub;

  Future<void> _onPreference(
    TransportPreferenceChanged e,
    Emitter<ConnectivityState> emit,
  ) async {
    await _manager.setTransportPreference(e.preference);
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
