enum Environment { dev, staging, prod }

class EnvConfig {
  final Environment environment;
  final String apiBaseUrl;

  EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
  });

  static late EnvConfig _instance;
  static EnvConfig get instance => _instance;

  static void init(EnvConfig config) {
    _instance = config;
  }
}
