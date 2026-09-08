import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../account/presentation/bloc/site_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/responsive.dart';
import '../../../connectivity/presentation/bloc/sync_cubit.dart';
import '../../../connectivity/presentation/widgets/connection_status_indicator.dart';

/// Bottom-nav (mobile) / nav-rail (wide) shell for the five tenant tabs.
class RootShell extends StatelessWidget {
  const RootShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (Icons.home_outlined, Icons.home, 'Home', Routes.home),
    (
      Icons.devices_other_outlined,
      Icons.devices_other,
      'Devices',
      Routes.devices,
    ),
    (Icons.insights_outlined, Icons.insights, 'Insights', Routes.insights),
    (
      Icons.auto_mode_outlined,
      Icons.auto_mode,
      'Automation',
      Routes.automation,
    ),
    (Icons.person_outline, Icons.person, 'Account', Routes.account),
  ];

  void _go(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    // Keep SiteBloc's tenant role in sync with the signed-in user.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => c is Authenticated,
      listener: (context, state) {
        if (state is Authenticated) {
          context.read<SiteBloc>()
            ..tenantRole = state.user.role
            ..add(const SitesSubscribed());
        }
      },
      child: context.isExpanded
          ? _WideLayout(shell: navigationShell, onSelect: _go)
          : Scaffold(
              body: Column(
                children: [
                  const _SyncBanner(),
                  Expanded(child: navigationShell),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _go,
                destinations: [
                  for (final d in _destinations)
                    NavigationDestination(
                      icon: Icon(d.$1),
                      selectedIcon: Icon(d.$2),
                      label: d.$3,
                    ),
                ],
              ),
            ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.shell, required this.onSelect});
  final StatefulNavigationShell shell;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: context.screenSize.width > 1200,
            selectedIndex: shell.currentIndex,
            onDestinationSelected: onSelect,
            leading: const Padding(
              padding: EdgeInsets.all(12),
              child: ConnectionStatusIndicator(),
            ),
            destinations: [
              for (final d in RootShell._destinations)
                NavigationRailDestination(
                  icon: Icon(d.$1),
                  selectedIcon: Icon(d.$2),
                  label: Text(d.$3),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: MaxWidthBox(maxWidth: 1200, child: shell)),
        ],
      ),
    );
  }
}

/// Thin banner shown while the outbox has queued writes.
class _SyncBanner extends StatelessWidget {
  const _SyncBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncViewState>(
      builder: (context, state) {
        if (!state.hasQueue) return const SizedBox.shrink();
        final syncing = state.status == SyncStatus.syncing;
        return Material(
          color: context.colors.secondaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    height: 14,
                    width: 14,
                    child: syncing
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(Icons.cloud_upload_outlined, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      syncing
                          ? 'Syncing ${state.pending} change'
                                '${state.pending == 1 ? '' : 's'}…'
                          : '${state.pending} change'
                                '${state.pending == 1 ? '' : 's'} waiting to sync',
                      style: context.textTheme.labelMedium,
                    ),
                  ),
                  if (!syncing)
                    TextButton(
                      onPressed: () => context.read<SyncCubit>().syncNow(),
                      child: const Text('Sync now'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Simple placeholder used for tabs whose real screens land in Phase 5.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: ConnectionStatusIndicator()),
          ),
        ],
      ),
      body: Center(
        child: Text(
          '$title\ncoming next',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
