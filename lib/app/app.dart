import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/config/env_config.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/connectivity/presentation/bloc/connectivity_bloc.dart';
import '../injection/injection.dart';
import 'router.dart';
import 'themes/theme.dart';

/// Root application widget. Global blocs are provided here; feature blocs are
/// provided at route level. Theme mode wires to `AppPreferences` in Phase 4.
class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = EnvConfig.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<ConnectivityBloc>()),
      ],
      child: Builder(
        builder: (context) {
          final router = buildRouter(context.read<AuthBloc>());
          return MaterialApp.router(
            title: config.appName,
            debugShowCheckedModeBanner: !config.isProd,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            routerConfig: router,
            supportedLocales: const [Locale('en'), Locale('sw')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
