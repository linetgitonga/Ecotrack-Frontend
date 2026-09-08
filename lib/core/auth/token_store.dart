import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../data/local/preferences/secure_storage.dart';

/// Holds the JWT pair for the current session.
///
///   * **access token** — memory only, 15-min TTL, never persisted.
///   * **refresh token** — `flutter_secure_storage` (Keychain / Keystore).
///
/// The refresh flow itself lives in `SessionManager` (Phase 3); this class is
/// the store plus a single-flight lock the auth interceptor waits on.
@lazySingleton
class TokenStore {
  TokenStore(this._secure);
  final SecureStorage _secure;

  String? _accessToken;
  int? _accessExpiresAtEpoch;

  /// `refresh_jti` claim of the active refresh token — used to flag the
  /// "current" row in `GET /auth/sessions`.
  String? currentRefreshJti;

  String? get accessToken => _accessToken;
  bool get hasAccessToken => _accessToken != null;

  bool get isAccessTokenExpired {
    final exp = _accessExpiresAtEpoch;
    if (exp == null) return _accessToken == null;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp;
  }

  DateTime? get accessTokenExpiry => _accessExpiresAtEpoch == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(_accessExpiresAtEpoch! * 1000);

  void setAccessToken(String token) {
    _accessToken = token;
    final claims = _decodeClaims(token);
    final exp = claims['exp'];
    _accessExpiresAtEpoch = exp is int ? exp : int.tryParse('${exp ?? ''}');
    currentRefreshJti = claims['refresh_jti']?.toString() ?? currentRefreshJti;
  }

  Future<void> setRefreshToken(String token) =>
      _secure.writeRefreshToken(token);
  Future<String?> readRefreshToken() => _secure.readRefreshToken();

  Future<void> setPair({
    required String access,
    required String refresh,
  }) async {
    setAccessToken(access);
    await _secure.writeRefreshToken(refresh);
  }

  Future<void> clear() async {
    _accessToken = null;
    _accessExpiresAtEpoch = null;
    currentRefreshJti = null;
    await _secure.clearAuth();
  }

  // --- Single-flight refresh lock -----------------------------------
  Completer<void>? _refreshLock;

  bool get isRefreshing => _refreshLock != null && !_refreshLock!.isCompleted;

  /// Begin a refresh; false if one is already running (caller should await).
  bool beginRefresh() {
    if (isRefreshing) return false;
    _refreshLock = Completer<void>();
    return true;
  }

  void endRefresh() {
    if (_refreshLock != null && !_refreshLock!.isCompleted) {
      _refreshLock!.complete();
    }
    _refreshLock = null;
  }

  Future<void> awaitRefresh() => _refreshLock?.future ?? Future<void>.value();

  /// Decode a JWT payload without verifying it (the server verifies).
  static Map<String, dynamic> _decodeClaims(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return const {};
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }
}
