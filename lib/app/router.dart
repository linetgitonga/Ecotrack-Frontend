import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_verify_page.dart';
import '../features/home/presentation/pages/home_placeholder_page.dart';
import '../features/shell/presentation/pages/splash_page.dart';

/// Route path constants — string-addressable so deep links and tests don't
/// hard-code literals.
abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/login/otp';
  static const onboardingSite = '/onboarding/site';

  static const home = '/home';
  static const devices = '/devices';
  static String device(String id) => '/devices/$id';
  static const addDevice = '/devices/add';
  static const insights = '/insights';
  static const automation = '/automation';
  static const alerts = '/alerts';

  static const account = '/account';
  static const accountSites = '/account/sites';
  static String siteMembers(String siteId) => '/account/sites/$siteId/members';
  static const sessions = '/account/sessions';
  static const preferences = '/account/preferences';
  static const privacy = '/account/privacy';
  static const subscription = '/account/subscription';
  static const hub = '/account/hub';
}

/// Bridges a [Stream] to the [Listenable] `GoRouter.refreshListenable` wants.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final s = authBloc.state;
      final loc = state.matchedLocation;

      final booting = s is AuthInitial || s is AuthRestoring;
      final authed = s is Authenticated;
      final inAuthFlow = loc == Routes.login || loc == Routes.otp;

      if (booting) return loc == Routes.splash ? null : Routes.splash;
      if (!authed) return inAuthFlow ? null : Routes.login;
      // authed:
      if (inAuthFlow || loc == Routes.splash) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.otp, builder: (_, _) => const OtpVerifyPage()),
      GoRoute(
        path: Routes.home,
        builder: (_, _) => const HomePlaceholderPage(),
      ),
    ],
  );
}
