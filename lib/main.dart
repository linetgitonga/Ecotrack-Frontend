import 'bootstrap.dart';
import 'core/config/env_config.dart';

/// Fallback entrypoint for IDE "Run" buttons and tooling that assumes
/// `lib/main.dart`. Defaults to the `dev` flavor.
///
/// CI and release builds MUST use the explicit flavored entrypoints
/// (`main_dev.dart` / `main_staging.dart` / `main_prod.dart`) together with the
/// matching `--flavor` argument.
Future<void> main() => bootstrap(Environment.dev);
