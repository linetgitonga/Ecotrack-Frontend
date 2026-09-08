import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

/// Non-secret, per-installation settings (System_Design §13.1: connection
/// preferences are device-side, never server-side). Backed by
/// `shared_preferences`. Every read tolerates a missing/blocked store.
@lazySingleton
class AppPreferences {
  AppPreferences(this._prefs);
  final SharedPreferences _prefs;

  // --- Theme ---------------------------------------------------------
  /// 'system' | 'light' | 'dark'
  String get themeMode => _prefs.getString(AppConstants.kThemeMode) ?? 'system';
  Future<void> setThemeMode(String v) =>
      _prefs.setString(AppConstants.kThemeMode, v);

  // --- Locale -------------------------------------------------------
  String? get localeCode => _prefs.getString(AppConstants.kLocale);
  Future<void> setLocaleCode(String? v) => v == null
      ? _prefs.remove(AppConstants.kLocale)
      : _prefs.setString(AppConstants.kLocale, v);

  // --- Session context -------------------------------------------
  String? get lastSiteId => _prefs.getString(AppConstants.kLastSiteId);
  Future<void> setLastSiteId(String? v) => v == null
      ? _prefs.remove(AppConstants.kLastSiteId)
      : _prefs.setString(AppConstants.kLastSiteId, v);

  bool get onboardingSeen =>
      _prefs.getBool(AppConstants.kOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool v) =>
      _prefs.setBool(AppConstants.kOnboardingSeen, v);

  // --- Connection preferences (device-side) ---------------------
  /// 'auto' | 'lan_only' | 'cloud_only'
  String get preferredTransport =>
      _prefs.getString(AppConstants.kPreferredTransport) ?? 'auto';
  Future<void> setPreferredTransport(String v) =>
      _prefs.setString(AppConstants.kPreferredTransport, v);

  Duration get lanTimeout => Duration(
    milliseconds:
        _prefs.getInt(AppConstants.kLanTimeoutMs) ??
        AppConstants.lanProbeTimeout.inMilliseconds,
  );
  Future<void> setLanTimeout(Duration d) =>
      _prefs.setInt(AppConstants.kLanTimeoutMs, d.inMilliseconds);

  /// 'mdns' | 'static_ip' | 'off'
  String get discoveryMode =>
      _prefs.getString(AppConstants.kDiscoveryMode) ?? 'mdns';
  Future<void> setDiscoveryMode(String v) =>
      _prefs.setString(AppConstants.kDiscoveryMode, v);

  /// Clear per-user context on logout (keeps theme / locale / connection prefs).
  Future<void> clearSessionScoped() async {
    await _prefs.remove(AppConstants.kLastSiteId);
  }
}
