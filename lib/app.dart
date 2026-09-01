import 'package:flutter/material.dart';
import 'core/config/env_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrack',
      home: Scaffold(
        appBar: AppBar(
          title: Text('EcoTrack - ${EnvConfig.instance.environment.name}'),
        ),
        body: Center(
          child: Text('API URL: ${EnvConfig.instance.apiBaseUrl}'),
        ),
      ),
    );
  }
}
