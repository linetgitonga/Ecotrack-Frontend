import 'package:flutter/material.dart';

import 'core/config/env_config.dart';

/// Root application widget.
///
/// Intentionally minimal — this repo is a CI/CD + architecture shell, not a
/// feature codebase. Feature modules should provide their own routing / theme
/// and be composed in here later.
class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = EnvConfig.instance;
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: !config.isProd,
      home: const _EnvDiagnosticsScreen(),
    );
  }
}

/// Temporary placeholder so a fresh clone builds and visibly confirms which
/// flavor / config is active. Delete once real features land.
class _EnvDiagnosticsScreen extends StatelessWidget {
  const _EnvDiagnosticsScreen();

  @override
  Widget build(BuildContext context) {
    final config = EnvConfig.instance;
    return Scaffold(
      appBar: AppBar(title: Text('${config.appName} · ${config.environment.name}')),
      body: Center(
        child: Text('API: ${config.apiBaseUrl}'),
      ),
    );
  }
}
