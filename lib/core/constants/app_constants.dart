/// Tunables that aren't environment-specific (those live in `EnvConfig` / `.env`).
abstract final class AppConstants {
  // --- Networking -------------------------------------------------------
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration lanProbeTimeout = Duration(seconds: 2);
  static const int maxRetries = 3;
  static const Duration retryBaseDelay = Duration(milliseconds: 400);

  // --- Auth -----------------------------------------------------------
  /// Refresh the access token this long before its `exp`.
  static const Duration refreshLeeway = Duration(seconds: 60);
  static const Duration otpResendCooldown = Duration(seconds: 45);
  static const int otpLength = 6;
  static const Duration stepUpElevationWindow = Duration(seconds: 300);

  // --- Sync / cache --------------------------------------------------
  /// A cached collection older than this triggers a background refresh.
  static const Duration defaultStaleness = Duration(minutes: 5);
  static const Duration foregroundPollInterval = Duration(minutes: 5);
  static const Duration backgroundSyncInterval = Duration(minutes: 15);

  /// telemetry_samples ring buffer caps.
  static const int telemetrySampleRowCap = 250000;
  static const Duration telemetrySampleMaxAge = Duration(days: 7);

  // --- Pagination --------------------------------------------------
  static const int defaultPageSize = 50;

  // --- Storage keys (shared_preferences) --------------------------
  static const String kThemeMode = 'pref.theme_mode';
  static const String kLocale = 'pref.locale';
  static const String kLastSiteId = 'pref.last_site_id';
  static const String kOnboardingSeen = 'pref.onboarding_seen';
  static const String kPreferredTransport = 'pref.preferred_transport';
  static const String kLanTimeoutMs = 'pref.lan_timeout_ms';
  static const String kDiscoveryMode = 'pref.discovery_mode';

  // --- Secure storage keys --------------------------------------
  static const String kRefreshToken = 'secure.refresh_token';
  static const String kBiometricEnabled = 'secure.biometric_enabled';
  static String kHubFingerprint(String hubId) => 'secure.hub_fp.$hubId';
  static String kHubLocalToken(String hubId) => 'secure.hub_token.$hubId';

  // --- Misc ------------------------------------------------------
  static const String currencyCode = 'KES';
  static const String defaultTimezone = 'Africa/Nairobi';
  static const String phoneCountryCode = '+254';
  static const String mdnsServiceType = '_ecotrack._tcp';
}
