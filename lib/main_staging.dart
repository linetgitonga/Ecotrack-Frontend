import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/env_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.staging");
  
  EnvConfig.init(EnvConfig(
    environment: Environment.staging,
    apiBaseUrl: dotenv.env['API_BASE_URL'] ?? 'https://staging.api.example.com',
  ));

  runApp(const MyApp());
}
