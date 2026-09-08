import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';

/// Keychain / Keystore-backed storage for the refresh token, pinned hub
/// certificate fingerprints, per-hub local bearer tokens, and the biometric
/// flag. The access token is **never** persisted (it lives in memory only).
@lazySingleton
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  // --- Refresh token -------------------------------------------------
  Future<String?> readRefreshToken() =>
      _storage.read(key: AppConstants.kRefreshToken);
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: AppConstants.kRefreshToken, value: token);
  Future<void> deleteRefreshToken() =>
      _storage.delete(key: AppConstants.kRefreshToken);

  // --- Biometric --------------------------------------------------
  Future<bool> get biometricEnabled async =>
      (await _storage.read(key: AppConstants.kBiometricEnabled)) == 'true';
  Future<void> setBiometricEnabled(bool v) =>
      _storage.write(key: AppConstants.kBiometricEnabled, value: '$v');

  // --- Hub trust (cert pinning) --------------------------------
  Future<String?> readHubFingerprint(String hubId) =>
      _storage.read(key: AppConstants.kHubFingerprint(hubId));
  Future<void> writeHubFingerprint(String hubId, String sha256) =>
      _storage.write(key: AppConstants.kHubFingerprint(hubId), value: sha256);

  Future<String?> readHubLocalToken(String hubId) =>
      _storage.read(key: AppConstants.kHubLocalToken(hubId));
  Future<void> writeHubLocalToken(String hubId, String token) =>
      _storage.write(key: AppConstants.kHubLocalToken(hubId), value: token);

  /// Wipe auth material on logout / revoke-all. Hub fingerprints are kept
  /// (they belong to the device's trust store, not the session).
  Future<void> clearAuth() async {
    await deleteRefreshToken();
  }
}
