import 'package:ecotrack/core/config/env_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initFromDotenv: env values win, defaults fill the gaps', () {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://from-env.example');

    final config = EnvConfig.initFromDotenv(
      Environment.staging,
      defaults: const {
        'APP_NAME': 'EcoTrack Staging',
        'API_BASE_URL': 'https://default.example',
        'ENABLE_LOGGING': 'true',
      },
    );

    expect(config.environment, Environment.staging);
    expect(config.apiBaseUrl, 'https://from-env.example');
    expect(config.appName, 'EcoTrack Staging');
    expect(config.enableLogging, isTrue);
    expect(config.isProd, isFalse);
  });
}
