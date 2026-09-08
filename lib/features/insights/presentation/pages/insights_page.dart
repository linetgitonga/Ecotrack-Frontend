import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../data/remote/api/tierb_api.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_charts.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../../../account/presentation/bloc/site_bloc.dart';
import '../../../connectivity/presentation/widgets/connection_status_indicator.dart';
import '../bloc/insights_cubit.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final c = getIt<InsightsCubit>();
        final s = context.read<SiteBloc>().state.selectedSiteId;
        if (s != null) c.load(s);
        return c;
      },
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView();

  @override
  Widget build(BuildContext context) {
    final siteId = context.select((SiteBloc b) => b.state.selectedSiteId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: EcoSpacing.md),
            child: Center(child: ConnectionStatusIndicator()),
          ),
        ],
      ),
      body: BlocBuilder<InsightsCubit, InsightsState>(
        builder: (context, state) {
          if (state.loading && state.cost == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.cost == null) {
            return ErrorStateView(
              message: state.error!,
              onRetry: () => siteId != null
                  ? context.read<InsightsCubit>().load(siteId)
                  : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => siteId != null
                ? context.read<InsightsCubit>().load(siteId)
                : null,
            child: ListView(
              padding: const EdgeInsets.all(EcoSpacing.lg),
              children: [
                if (state.cost != null) _CostCard(cost: state.cost!),
                const SizedBox(height: EcoSpacing.lg),
                _Section(
                  title: 'Top consumers this month',
                  child: state.breakdown.isEmpty
                      ? const EmptyState(message: 'No breakdown available')
                      : ShareBars(
                          rows: [
                            for (final s in state.breakdown)
                              (
                                s.label,
                                s.amount.formattedWithEstimate,
                                s.share,
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: EcoSpacing.lg),
                _Section(
                  title: 'Spend trend (7 days)',
                  child: UsageLineChart(
                    values: state.trend,
                    unitSuffix: ' KES',
                  ),
                ),
                const SizedBox(height: EcoSpacing.lg),
                _Section(
                  title: 'Recommendations',
                  child: Column(
                    children: [
                      for (final r in state.recommendations)
                        Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.tips_and_updates_outlined,
                            ),
                            title: Text(r.title),
                            subtitle: Text(r.detail),
                            trailing: r.estimatedSaving == null
                                ? null
                                : Text(
                                    '~${r.estimatedSaving!.formatted}',
                                    style: context.textTheme.labelMedium,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({required this.cost});
  final CostSummary cost;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcoSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This month so far', style: context.textTheme.labelMedium),
            Text(
              cost.monthToDate.formattedWithEstimate,
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: EcoSpacing.sm),
            Text(
              '${cost.kwhAccumulated.toStringAsFixed(1)} kWh · '
              '${cost.marginalRate.formatted}/kWh'
              '${cost.bandPosition == null ? '' : ' · ${cost.bandPosition}'}',
              style: context.textTheme.bodySmall,
            ),
            if (cost.isEstimated) ...[
              const SizedBox(height: EcoSpacing.xs),
              Text(
                '≈ Estimated until prepaid token data is available.',
                style: context.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.titleMedium),
        const SizedBox(height: EcoSpacing.sm),
        child,
      ],
    );
  }
}
