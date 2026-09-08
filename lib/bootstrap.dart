import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/config/env_config.dart';
import 'core/connectivity/connection_manager.dart';
import 'core/sync/outbox_processor.dart';
import 'core/sync/sync_engine.dart';
import 'data/repositories/device_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'injection/injection.dart';

/// Per-environment dotenv asset filename.
const _dotenvFileByEnv = <Environment, String>{
  Environment.dev: '.env.dev',
  Environment.staging: '.env.staging',
  Environment.prod: '.env.prod',
};

/// Compile-time-safe fallbacks. Real values come from the injected `.env.*`
/// asset (CI writes it from a GitHub Secret; see docs/devops-setup.md).
const _defaultsByEnv = <Environment, Map<String, String>>{
  Environment.dev: {
    'APP_NAME': 'EcoTrack Dev',
    'API_BASE_URL': 'https://dev.api.ecotrack.co.ke/v1',
    'ENABLE_LOGGING': 'true',
  },
  Environment.staging: {
    'APP_NAME': 'EcoTrack Staging',
    'API_BASE_URL': 'https://staging.api.ecotrack.co.ke/v1',
    'ENABLE_LOGGING': 'true',
  },
  Environment.prod: {
    'APP_NAME': 'EcoTrack',
    'API_BASE_URL': 'https://api.ecotrack.co.ke/v1',
    'ENABLE_LOGGING': 'false',
  },
};

/// Single shared startup path for every flavor.
///
/// Each `main_<env>.dart` is a one-liner that calls this with its [environment].
/// Keeps initialization order identical across dev/staging/prod so bugs can't
/// hide in a flavor: bindings → dotenv → config → DI → error handlers → runApp.
Future<void> bootstrap(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Missing/!bundled .env => fall back to compiled-in defaults instead of
  // hard-crashing (e.g. a fresh clone with no `.env.dev`).
  try {
    await dotenv.load(fileName: _dotenvFileByEnv[environment]!);
  } catch (_) {
    dotenv.testLoad(fileInput: '');
  }

  final config = EnvConfig.initFromDotenv(
    environment,
    defaults: _defaultsByEnv[environment]!,
  );

  await configureDependencies(config);

  // Register outbox handlers before the sync engine drains anything.
  getIt<OutboxProcessor>().register(
    'command',
    getIt<DeviceRepository>().handleQueuedCommand,
  );

  // Start the connection state machine + sync engine (non-blocking).
  unawaited(getIt<ConnectionManager>().start());
  getIt<SyncEngine>().start();

  // Kick off session restore — the router shows a splash until it resolves.
  // (AuthBloc's constructor also wires SessionManager into the auth interceptor.)
  getIt<AuthBloc>().add(const AuthStarted());

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Hook point: forward to crash reporting when config.sentryDsn is set.
  };

  runZonedGuarded(() => runApp(const EcoTrackApp()), (error, stack) {
    if (config.enableLogging) {
      debugPrint('Uncaught zone error: $error\n$stack');
    }
    // Hook point: forward to crash reporting.
  });
}
