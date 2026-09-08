import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../core/config/env_config.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Wires the object graph. Called once from `bootstrap.dart` after `EnvConfig`
/// is initialised. [env] is registered so `@Environment`-scoped and
/// config-dependent registrations can read it.
///
/// Run codegen after changing any `@injectable` / `@module` annotation:
///   dart run build_runner build --delete-conflicting-outputs
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies(EnvConfig env) async {
  getIt.registerSingleton<EnvConfig>(env);
  await getIt.init();
}

/// Registration environments (see `@Environment(...)` on impls).
abstract final class Env {
  static const String mock = 'mock';
  static const String live = 'live';
}
