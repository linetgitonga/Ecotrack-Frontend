import 'package:flutter_dotenv/flutter_dotenv.dart';

/// The build environment (flavor) the app is currently running as.
enum Environment { dev, staging, prod }

/// Immutable, globally-accessible environment configuration.
///
/// Populated exactly once from a flavored entrypoint (`main_<env>.dart`) via
/// [EnvConfig.initFromDotenv] before `runApp()` is called. Never mutate after
/// [init]; treat [instance] as read-only for the lifetime of the process.
class EnvConfig {
  EnvConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.sentryDsn,
    required this.enableLogging,
    this.mockMode = false,
  });

  final Environment environment;
  final String appName;
  final String apiBaseUrl;

  /// Optional crash-reporting DSN. Empty string => reporting disabled.
  final String sentryDsn;

  /// Verbose logging / debug tooling. Should be false for `prod`.
  final bool enableLogging;

  /// When true, Tier-B endpoints (System_Design §8, not yet deployed) are
  /// served from `data/remote/mock/fixtures`. Default: on for `dev`.
  final bool mockMode;

  bool get isProd => environment == Environment.prod;

  static EnvConfig? _instance;

  /// The active configuration. Throws if accessed before [init].
  static EnvConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError(
        'EnvConfig accessed before initialization. '
        'Run the app via a flavored entrypoint (main_dev.dart / '
        'main_staging.dart / main_prod.dart).',
      );
    }
    return config;
  }

  static void init(EnvConfig config) => _instance = config;

  /// Builds an [EnvConfig] from the already-loaded dotenv map.
  ///
  /// `dotenv.load()` MUST have been awaited before calling this.
  /// [defaults] provides safe fallbacks so a missing key never hard-crashes
  /// a release build.
  static EnvConfig initFromDotenv(
    Environment environment, {
    required Map<String, String> defaults,
  }) {
    String read(String key) => dotenv.env[key] ?? defaults[key] ?? '';

    final mockRaw = read('ENABLE_MOCK').toLowerCase();
    final config = EnvConfig(
      environment: environment,
      appName: read('APP_NAME'),
      apiBaseUrl: read('API_BASE_URL'),
      sentryDsn: read('SENTRY_DSN'),
      enableLogging: read('ENABLE_LOGGING').toLowerCase() == 'true',
      mockMode: mockRaw.isEmpty
          ? environment == Environment.dev
          : mockRaw == 'true',
    );
    init(config);
    return config;
  }
}
