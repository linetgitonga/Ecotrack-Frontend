import 'bootstrap.dart';
import 'core/config/env_config.dart';

/// Entrypoint for the `staging` flavor:
///   flutter run --flavor staging -t lib/main_staging.dart
Future<void> main() => bootstrap(Environment.staging);
