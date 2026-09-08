import 'package:injectable/injectable.dart';

import 'interceptors/auth_interceptor.dart';

/// Mutable seam between the network layer (built early) and the pieces that
/// depend on it (`SessionManager`, `ConnectionManager` — Phase 2b/3). The Dio
/// interceptors read through this holder, so those can be plugged in after the
/// object graph is up without a construction cycle.
@lazySingleton
class NetworkWiring {
  TokenRefresher _refresher = const _NoRefresher();
  void Function()? _onSessionLost;
  Future<bool> Function() _hasConnection = () async => true;

  TokenRefresher get refresher => _refresher;
  void Function()? get onSessionLost => _onSessionLost;
  Future<bool> hasConnection() => _hasConnection();

  void useRefresher(
    TokenRefresher refresher, {
    void Function()? onSessionLost,
  }) {
    _refresher = refresher;
    _onSessionLost = onSessionLost;
  }

  void useConnectivity(Future<bool> Function() hasConnection) {
    _hasConnection = hasConnection;
  }
}

class _NoRefresher implements TokenRefresher {
  const _NoRefresher();
  @override
  Future<String?> refresh() async => null;
}
