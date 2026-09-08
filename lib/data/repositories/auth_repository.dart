import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../core/auth/token_store.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/phone_number.dart';
import '../../domain/value_objects/role.dart';
import '../local/database/app_database.dart';
import '../local/preferences/app_preferences.dart';
import '../remote/api/auth_api.dart';
import '../remote/api/me_api.dart';
import '../remote/dto/user_dto.dart';

/// Auth + session orchestration over the Tier-A endpoints.
@lazySingleton
class AuthRepository {
  AuthRepository(this._auth, this._me, this._tokens, this._db, this._prefs);

  final AuthApi _auth;
  final MeApi _me;
  final TokenStore _tokens;
  final AppDatabase _db;
  final AppPreferences _prefs;

  /// `POST /auth/otp/request` — also creates a tenant + owner for a new phone.
  Future<Result<OtpChallenge>> requestOtp(
    PhoneNumber phone, {
    String? deviceName,
  }) async {
    final r = await _auth.requestOtp(
      phoneE164: phone.e164,
      deviceName: deviceName,
    );
    return r.map(
      (d) => OtpChallenge(
        pendingToken: d.pendingToken,
        maskedTarget: d.maskedTarget ?? phone.masked,
        expiresIn: Duration(seconds: d.expiresIn),
      ),
    );
  }

  Future<Result<Unit>> resendOtp(String pendingToken) =>
      _auth.resendOtp(pendingToken);

  /// Exchange the code, persist the pair, load `/me`.
  Future<Result<User>> verifyOtp({
    required String pendingToken,
    required String code,
    String? deviceName,
  }) async {
    final pair = await _auth.verifyOtp(
      pendingToken: pendingToken,
      code: code,
      deviceName: deviceName,
    );
    return pair.when(
      err: Err<User>.new,
      ok: (tokens) async {
        await _tokens.setPair(access: tokens.access, refresh: tokens.refresh);
        return _loadMe();
      },
    );
  }

  /// Restore a session on cold start: if a refresh token exists, rotate it and
  /// load `/me`. Returns null-in-Ok semantics via [Failure] on any problem.
  Future<Result<User>> restoreSession() async {
    final refresh = await _tokens.readRefreshToken();
    if (refresh == null) {
      return const Err(UnauthorizedFailure(message: 'No stored session'));
    }
    final rotated = await _auth.refresh(refresh);
    return rotated.when(
      err: (f) async {
        if (f is UnauthorizedFailure) await _tokens.clear();
        return Err<User>(f);
      },
      ok: (tokens) async {
        await _tokens.setPair(access: tokens.access, refresh: tokens.refresh);
        return _loadMe();
      },
    );
  }

  Future<Result<User>> reloadMe() => _loadMe();

  Future<Result<User>> updateProfile({
    String? displayName,
    String? locale,
  }) async {
    final r = await _me.updateMe(displayName: displayName, locale: locale);
    return r.map(_toUser);
  }

  Future<void> logout() async {
    final refresh = await _tokens.readRefreshToken();
    if (refresh != null) {
      await _auth.logout(refresh); // best-effort
    }
    await _wipeLocal();
  }

  Future<Result<int>> revokeAllSessions() async {
    final r = await _auth.revokeAllSessions();
    if (r.isOk) await _wipeLocal();
    return r;
  }

  Future<Result<List<AuthSession>>> sessions() async {
    final r = await _auth.sessions();
    return r.map(
      (list) => list
          .map(
            (d) => AuthSession(
              id: d.sessionId,
              isCurrent: d.isCurrent,
              deviceName: d.deviceName,
              ipAddress: d.ipAddress,
              loginAt: d.loginAt,
              lastActivity: d.lastActivity,
              expiresAt: d.expiresAt,
            ),
          )
          .toList(),
    );
  }

  Future<Result<Unit>> revokeSession(String id) => _auth.revokeSession(id);

  // --- internal -----------------------------------------------------
  Future<Result<User>> _loadMe() async {
    final r = await _me.me();
    return r.when(
      err: (f) async {
        if (f is UnauthorizedFailure) await _tokens.clear();
        return Err<User>(f);
      },
      ok: (dto) async {
        await _cacheUser(dto);
        return Ok(_toUser(dto));
      },
    );
  }

  User _toUser(UserDto d) => User(
    id: d.id,
    tenantId: d.tenant,
    phone:
        PhoneNumber.tryParse(d.phoneE164) ??
        (throw StateError('bad phone from /me')),
    role: Role.fromApi(d.role),
    displayName: d.displayName,
    email: d.email,
    locale: d.locale,
    status: d.status,
    lastLoginAt: d.lastLoginAt,
  );

  Future<void> _cacheUser(UserDto d) async {
    await _db
        .into(_db.cachedUsers)
        .insertOnConflictUpdate(
          CachedUsersCompanion.insert(
            id: d.id,
            tenantId: d.tenant,
            phoneE164: d.phoneE164,
            email: Value(d.email),
            displayName: Value(d.displayName),
            role: d.role,
            locale: Value(d.locale),
            status: Value(d.status),
            lastLoginAt: Value(d.lastLoginAt),
            cachedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _wipeLocal() async {
    await _tokens.clear();
    await _db.clearUserData();
    await _prefs.clearSessionScoped();
  }
}

/// Value returned to the OTP screen.
class OtpChallenge {
  const OtpChallenge({
    required this.pendingToken,
    required this.maskedTarget,
    required this.expiresIn,
  });
  final String pendingToken;
  final String maskedTarget;
  final Duration expiresIn;
}
