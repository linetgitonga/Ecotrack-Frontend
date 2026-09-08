import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../../../account/presentation/bloc/site_bloc.dart';
import '../bloc/portfolio_cubit.dart';

/// Multi-site owner view: portfolio overview + units + billing + maintenance
/// in one tabbed screen. Reached from Account when the owner has >1 site.
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sites = context.read<SiteBloc>().state.sites;
    return BlocProvider(
      create: (_) => getIt<PortfolioCubit>()..load(sites),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Portfolio'),
            bottom: const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Units'),
                Tab(text: 'Billing'),
                Tab(text: 'Maintenance'),
              ],
            ),
          ),
          body: BlocBuilder<PortfolioCubit, PortfolioState>(
            builder: (context, state) {
              if (state.loading && state.units.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.units.isEmpty) {
                return const EmptyState(
                  icon: Icons.apartment_outlined,
                  message: 'Add a second site to see the portfolio view',
                );
              }
              return TabBarView(
                children: [
                  _Overview(state: state),
                  _Units(state: state),
                  _Billing(state: state),
                  _Maintenance(state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.state});
  final PortfolioState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(EcoSpacing.lg),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.7,
          crossAxisSpacing: EcoSpacing.sm,
          mainAxisSpacing: EcoSpacing.sm,
          children: [
            _Metric('Live load', Formatters.watts(state.totalWatts)),
            _Metric('Today', Formatters.kwh(state.totalTodayKwh)),
            _Metric('Month cost', state.totalMonthCost.formattedWithEstimate),
            _Metric('Units', '${state.unitCount}'),
            _Metric('Open alerts', '${state.totalOpenAlerts}'),
            _Metric('Need attention', '${state.unitsNeedingAttention}'),
          ],
        ),
        const SizedBox(height: EcoSpacing.lg),
        Text('Critical alerts', style: context.textTheme.titleMedium),
        const SizedBox(height: EcoSpacing.sm),
        if (state.criticalAlerts.isEmpty)
          const EmptyState(message: 'No critical alerts across your sites')
        else
          for (final c in state.criticalAlerts)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.error_outline,
                  color: EcoColors.error,
                ),
                title: Text(c.alert.title),
                subtitle: Text('${c.siteLabel} · ${c.alert.description}'),
              ),
            ),
      ],
    );
  }
}

class _Units extends StatelessWidget {
  const _Units({required this.state});
  final PortfolioState state;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(EcoSpacing.lg),
      itemCount: state.units.length,
      separatorBuilder: (_, _) => const SizedBox(height: EcoSpacing.sm),
      itemBuilder: (context, i) {
        final u = state.units[i];
        return Card(
          child: ListTile(
            title: Text(u.site.label),
            subtitle: Text(
              '${Formatters.watts(u.liveWatts)} · '
              '${Formatters.kwh(u.todayKwh)} today · '
              '${u.monthCost.formattedWithEstimate} this month',
            ),
            trailing: Chip(
              label: Text(u.status),
              backgroundColor: u.openAlerts > 0
                  ? EcoColors.warning.withValues(alpha: 0.16)
                  : null,
              visualDensity: VisualDensity.compact,
            ),
            onTap: () => context.push(Routes.portfolioUnit(u.site.id)),
          ),
        );
      },
    );
  }
}

class _Billing extends StatelessWidget {
  const _Billing({required this.state});
  final PortfolioState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(EcoSpacing.lg),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(EcoSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This billing period',
                  style: context.textTheme.labelMedium,
                ),
                Text(
                  state.totalMonthCost.formattedWithEstimate,
                  style: context.textTheme.headlineMedium,
                ),
                Text(
                  'across ${state.unitCount} units',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: EcoSpacing.lg),
        Text('Allocation by unit', style: context.textTheme.titleMedium),
        const SizedBox(height: EcoSpacing.sm),
        for (final u in state.units)
          Card(
            child: ListTile(
              title: Text(u.site.label),
              subtitle: Text(u.estimated ? 'Estimated' : 'Metered'),
              trailing: Text(
                u.monthCost.formatted,
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
        const SizedBox(height: EcoSpacing.lg),
        OutlinedButton.icon(
          onPressed: () => context.showSnack('CSV export — coming soon'),
          icon: const Icon(Icons.download),
          label: const Text('Export statement (CSV)'),
        ),
      ],
    );
  }
}

class _Maintenance extends StatelessWidget {
  const _Maintenance({required this.state});
  final PortfolioState state;

  @override
  Widget build(BuildContext context) {
    final attention = state.units.where((u) => u.openAlerts > 0).toList();
    final offline = state.units.where((u) => !u.site.isActive).toList();
    return ListView(
      padding: const EdgeInsets.all(EcoSpacing.lg),
      children: [
        _Metric('Sites OK', '${state.unitCount - attention.length}'),
        const SizedBox(height: EcoSpacing.lg),
        Text('Needs attention', style: context.textTheme.titleMedium),
        const SizedBox(height: EcoSpacing.sm),
        if (attention.isEmpty)
          const EmptyState(message: 'Everything looks healthy')
        else
          for (final u in attention)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.build_outlined,
                  color: EcoColors.warning,
                ),
                title: Text(u.site.label),
                subtitle: Text(
                  '${u.openAlerts} open alert'
                  '${u.openAlerts == 1 ? '' : 's'}',
                ),
                onTap: () => context.push(Routes.portfolioUnit(u.site.id)),
              ),
            ),
        if (offline.isNotEmpty) ...[
          const SizedBox(height: EcoSpacing.lg),
          Text('Inactive sites', style: context.textTheme.titleMedium),
          for (final u in offline)
            Card(child: ListTile(title: Text(u.site.label))),
        ],
        const SizedBox(height: EcoSpacing.lg),
        OutlinedButton.icon(
          onPressed: () =>
              context.showSnack('Schedule maintenance — coming soon'),
          icon: const Icon(Icons.event),
          label: const Text('Schedule maintenance'),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: context.textTheme.titleLarge),
            Text(label, style: context.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
