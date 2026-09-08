import 'bootstrap.dart';
import 'core/config/env_config.dart';

/// Entrypoint for the `dev` flavor:
///   flutter run --flavor dev -t lib/main_dev.dart
Future<void> main() => bootstrap(Environment.dev);
