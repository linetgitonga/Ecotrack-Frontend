import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/account/presentation/bloc/site_bloc.dart';
import '../features/account/presentation/pages/account_page.dart';
import '../features/account/presentation/pages/audit_log_page.dart';
import '../features/account/presentation/pages/members_page.dart';
import '../features/account/presentation/pages/onboarding_site_page.dart';
import '../features/account/presentation/pages/profile_edit_page.dart';
import '../features/account/presentation/pages/sessions_page.dart';
import '../features/account/presentation/pages/site_form_page.dart';
import '../features/account/presentation/pages/sites_page.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/alerts/presentation/pages/alerts_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_verify_page.dart';
import '../features/automation/presentation/pages/automation_page.dart';
import '../features/devices/presentation/pages/device_detail_page.dart';
import '../features/devices/presentation/pages/devices_page.dart';
import '../features/devices/presentation/pages/pairing_page.dart';
import '../features/home/presentation/pages/home_dashboard_page.dart';
import '../features/insights/presentation/pages/insights_page.dart';
import '../features/shell/presentation/pages/root_shell.dart';
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

/// Bridges one or more [Stream]s to the [Listenable] `refreshListenable` wants.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    notifyListeners();
    for (final s in streams) {
      _subs.add(s.asBroadcastStream().listen((_) => notifyListeners()));
    }
  }
  final _subs = <StreamSubscription<dynamic>>[];

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}

final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AuthBloc authBloc, SiteBloc siteBloc) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: GoRouterRefreshStream([
      authBloc.stream,
      siteBloc.stream,
    ]),
    redirect: (context, state) {
      final a = authBloc.state;
      final loc = state.matchedLocation;
      final booting = a is AuthInitial || a is AuthRestoring;
      final authed = a is Authenticated;
      final inAuthFlow = loc == Routes.login || loc == Routes.otp;

      if (booting) return loc == Routes.splash ? null : Routes.splash;
      if (!authed) return inAuthFlow ? null : Routes.login;

      final needsOnboarding = siteBloc.state.hasNoSites;
      if (needsOnboarding) {
        return loc == Routes.onboardingSite ? null : Routes.onboardingSite;
      }
      if (inAuthFlow || loc == Routes.splash || loc == Routes.onboardingSite) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.otp, builder: (_, _) => const OtpVerifyPage()),
      GoRoute(
        path: Routes.onboardingSite,
        builder: (_, _) => const OnboardingSitePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => RootShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, _) => const HomeDashboardPage(),
                routes: [
                  GoRoute(
                    path: 'alerts',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const AlertsPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.devices,
                builder: (_, _) => const DevicesPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const PairingPage(),
                  ),
                  GoRoute(
                    path: ':deviceId',
                    parentNavigatorKey: _rootKey,
                    builder: (_, s) =>
                        DeviceDetailPage(deviceId: s.pathParameters['deviceId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.insights,
                builder: (_, _) => const InsightsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.automation,
                builder: (_, _) => const AutomationPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.account,
                builder: (_, _) => const AccountPage(),
                routes: [
                  GoRoute(
                    path: 'sites',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const SitesPage(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (_, _) => const SiteFormPage(),
                      ),
                      GoRoute(
                        path: ':siteId/edit',
                        builder: (_, s) =>
                            SiteFormPage(siteId: s.pathParameters['siteId']),
                      ),
                      GoRoute(
                        path: ':siteId/members',
                        builder: (_, s) =>
                            MembersPage(siteId: s.pathParameters['siteId']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'sessions',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const SessionsPage(),
                  ),
                  GoRoute(
                    path: 'preferences',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const ProfileEditPage(),
                  ),
                  GoRoute(
                    path: 'audit',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const AuditLogPage(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const TabPlaceholder('Privacy & data'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
