import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/value_objects/money.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../../../account/presentation/bloc/site_bloc.dart';
import '../../../account/presentation/widgets/site_selector.dart';
import '../../../connectivity/presentation/widgets/connection_status_indicator.dart';
import '../bloc/home_dashboard_bloc.dart';
import '../widgets/mode_switcher.dart';
import '../widgets/quick_controls.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeDashboardBloc>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final siteId = context.select((SiteBloc b) => b.state.selectedSiteId);

    return BlocListener<SiteBloc, SiteState>(
      listenWhen: (p, c) => p.selectedSiteId != c.selectedSiteId,
      listener: (context, state) {
        if (state.selectedSiteId != null) {
          context.read<HomeDashboardBloc>().add(
            DashboardSubscribed(state.selectedSiteId!),
          );
        }
      },
      child: Builder(
        builder: (context) {
          if (siteId != null &&
              context.read<HomeDashboardBloc>().state.status ==
                  DashboardStatus.initial) {
            context.read<HomeDashboardBloc>().add(DashboardSubscribed(siteId));
          }
          return Scaffold(
            appBar: AppBar(
              title: const SiteSelector(),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: EcoSpacing.md),
                  child: Center(child: ConnectionStatusIndicator()),
                ),
              ],
            ),
            body: BlocConsumer<HomeDashboardBloc, HomeDashboardState>(
              listenWhen: (p, c) => c.error != null && p.error != c.error,
              listener: (context, state) => context.showSnack(state.error!),
              builder: (context, state) {
                if (state.status == DashboardStatus.loading &&
                    state.usage == null) {
                  return const _DashboardSkeleton();
                }
                if (state.status == DashboardStatus.error &&
                    state.usage == null) {
                  return ErrorStateView(
                    message: state.error ?? 'Could not load your dashboard',
                    onRetry: () => context.read<HomeDashboardBloc>().add(
                      const DashboardRefreshed(),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<HomeDashboardBloc>().add(
                    const DashboardRefreshed(),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(EcoSpacing.lg),
                    children: [
                      if (state.unreadAlerts > 0)
                        _AlertBanner(count: state.unreadAlerts),
                      _LiveUsageCard(state: state),
                      const SizedBox(height: EcoSpacing.lg),
                      ModeSwitcher(
                        modes: state.modes,
                        onSelect: (id) => context.read<HomeDashboardBloc>().add(
                          DashboardModeSelected(id),
                        ),
                      ),
                      const SizedBox(height: EcoSpacing.lg),
                      Text(
                        'Quick controls',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: EcoSpacing.sm),
                      QuickControls(
                        devices: state.quickDevices,
                        onToggle: (id) => context.read<HomeDashboardBloc>().add(
                          DashboardQuickToggled(id),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LiveUsageCard extends StatelessWidget {
  const _LiveUsageCard({required this.state});
  final HomeDashboardState state;

  @override
  Widget build(BuildContext context) {
    final u = state.usage;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcoSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Right now', style: context.textTheme.labelMedium),
            const SizedBox(height: EcoSpacing.xs),
            Text(
              u == null ? '—' : Formatters.watts(u.liveWatts),
              style: context.textTheme.displaySmall?.copyWith(
                color: EcoColors.primary,
              ),
            ),
            const SizedBox(height: EcoSpacing.md),
            Row(
              children: [
                _Metric(
                  label: 'Today',
                  value: u == null ? '—' : Formatters.kwh(u.todayKwh),
                ),
                const SizedBox(width: EcoSpacing.xl),
                _Metric(
                  label: 'Estimated cost',
                  value: u == null
                      ? '—'
                      : Money.fromDouble(
                          u.todayKes,
                          isEstimated: u.isEstimated,
                        ).formattedWithEstimate,
                ),
              ],
            ),
            if (u?.budgetProgress != null) ...[
              const SizedBox(height: EcoSpacing.md),
              LinearProgressIndicator(
                value: u!.budgetProgress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: EcoSpacing.xs),
              Text(
                '${Formatters.percent(u.budgetProgress!)} of today\'s budget',
                style: context.textTheme.bodySmall,
              ),
            ],
            if (u?.isEstimated ?? false) ...[
              const SizedBox(height: EcoSpacing.sm),
              Text(
                '≈ Costs are estimated until token data is available.',
                style: context.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelMedium),
        Text(value, style: context.textTheme.titleMedium),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.lg),
      child: Material(
        color: EcoColors.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(EcoRadii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(EcoRadii.md),
          onTap: () => context.go('${Routes.home}/alerts'),
          child: Padding(
            padding: const EdgeInsets.all(EcoSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: EcoColors.warning,
                ),
                const SizedBox(width: EcoSpacing.sm),
                Expanded(
                  child: Text(
                    '$count unread alert${count == 1 ? '' : 's'}',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(EcoSpacing.lg),
    children: const [
      LoadingShimmer(height: 140),
      SizedBox(height: EcoSpacing.lg),
      LoadingShimmer(height: 64),
      SizedBox(height: EcoSpacing.lg),
      LoadingShimmer(height: 180),
    ],
  );
}
