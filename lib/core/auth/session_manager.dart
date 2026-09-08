import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../data/remote/api/auth_api.dart';
import '../constants/app_constants.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/network_wiring.dart';
import 'token_store.dart';

/// Owns the refresh lifecycle: implements [TokenRefresher] for the auth
/// interceptor, and schedules a pre-emptive refresh before the access token
/// expires. Wired into the network layer via [NetworkWiring] in `bootstrap`.
@lazySingleton
class SessionManager implements TokenRefresher {
  SessionManager(this._auth, this._tokens, this._wiring);

  final AuthApi _auth;
  final TokenStore _tokens;
  final NetworkWiring _wiring;

  Timer? _refreshTimer;

  /// Called by `bootstrap` once DI is up.
  void attach({required void Function() onSessionLost}) {
    _onSessionLost = onSessionLost;
    _wiring.useRefresher(this, onSessionLost: _handleSessionLost);
  }

  void Function()? _onSessionLost;

  /// (Re)start the pre-emptive refresh timer after a successful auth.
  void scheduleProactiveRefresh() {
    _refreshTimer?.cancel();
    final expiry = _tokens.accessTokenExpiry;
    if (expiry == null) return;
    final fireIn =
        expiry.difference(DateTime.now()) - AppConstants.refreshLeeway;
    if (fireIn.isNegative) {
      unawaited(refresh());
      return;
    }
    _refreshTimer = Timer(fireIn, () => unawaited(refresh()));
  }

  void cancel() => _refreshTimer?.cancel();

  @override
  Future<String?> refresh() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) return null;

    final r = await _auth.refresh(refreshToken);
    return r.when(
      ok: (pair) async {
        await _tokens.setPair(access: pair.access, refresh: pair.refresh);
        scheduleProactiveRefresh();
        return pair.access;
      },
      err: (_) async {
        await _tokens.clear();
        return null;
      },
    );
  }

  void _handleSessionLost() {
    cancel();
    _onSessionLost?.call();
  }
}
