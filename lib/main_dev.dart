import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/env_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.dev");
  
  EnvConfig.init(EnvConfig(
    environment: Environment.dev,
    apiBaseUrl: dotenv.env['API_BASE_URL'] ?? 'https://dev.api.example.com',
  ));

  runApp(const MyApp());
}
