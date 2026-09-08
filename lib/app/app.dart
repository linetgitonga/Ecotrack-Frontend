import 'package:flutter/material.dart';

import '../core/config/env_config.dart';
import 'themes/theme.dart';

/// Root application widget.
///
/// Phase 1: themed [MaterialApp] with a diagnostics home. Phase 3 swaps `home:`
/// for `MaterialApp.router(routerConfig: …)` once `AppRouter` + `AuthBloc` exist,
/// and wires `themeMode` to `AppPreferences`.
class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = EnvConfig.instance;
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: !config.isProd,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _EnvDiagnosticsScreen(),
    );
  }
}

/// Temporary placeholder so a fresh clone builds and shows which flavor/config
/// is active. Removed once real routing + the first screens land (Phase 3).
class _EnvDiagnosticsScreen extends StatelessWidget {
  const _EnvDiagnosticsScreen();

  @override
  Widget build(BuildContext context) {
    final config = EnvConfig.instance;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${config.appName} · ${config.environment.name}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('EcoTrack', style: t.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('API: ${config.apiBaseUrl}', style: t.textTheme.bodyMedium),
              Text(
                'logging: ${config.enableLogging}',
                style: t.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
