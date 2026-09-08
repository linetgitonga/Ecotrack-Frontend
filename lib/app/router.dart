import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Route path constants — string-addressable so deep links and tests don't
/// hard-code literals. The full route tree (shells, guards, feature blocs) is
/// assembled in Phase 3 once `AuthBloc` exists.
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

/// Signature for the auth-aware redirect, supplied by Phase 3 from `AuthBloc`.
typedef AuthRedirect =
    String? Function(BuildContext context, GoRouterState state);

/// Builds the app router. Phase 1 exposes the shape; [redirect] and
/// [refreshListenable] are injected later so routing reacts to auth changes.
GoRouter buildRouter({
  AuthRedirect? redirect,
  Listenable? refreshListenable,
  List<RouteBase> routes = const [],
  String initialLocation = Routes.splash,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: redirect,
    refreshListenable: refreshListenable,
    routes: routes,
  );
}
