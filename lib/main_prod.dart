import 'bootstrap.dart';
import 'core/config/env_config.dart';

/// Entrypoint for the `prod` flavor:
///   flutter build appbundle --flavor prod -t lib/main_prod.dart
Future<void> main() => bootstrap(Environment.prod);
