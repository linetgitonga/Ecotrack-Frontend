import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../../../account/presentation/bloc/site_bloc.dart';
import '../../../connectivity/presentation/widgets/connection_status_indicator.dart';
import '../../../home/presentation/widgets/mode_switcher.dart';
import '../bloc/automation_cubit.dart';

class AutomationPage extends StatelessWidget {
  const AutomationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final c = getIt<AutomationCubit>();
        final s = context.read<SiteBloc>().state.selectedSiteId;
        if (s != null) c.load(s);
        return c;
      },
      child: const _AutomationView(),
    );
  }
}

class _AutomationView extends StatelessWidget {
  const _AutomationView();

  @override
  Widget build(BuildContext context) {
    final siteId = context.select((SiteBloc b) => b.state.selectedSiteId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: EcoSpacing.md),
            child: Center(child: ConnectionStatusIndicator()),
          ),
        ],
      ),
      body: BlocBuilder<AutomationCubit, AutomationState>(
        builder: (context, state) {
          if (state.loading && state.modes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async => siteId != null
                ? context.read<AutomationCubit>().load(siteId)
                : null,
            child: ListView(
              padding: const EdgeInsets.all(EcoSpacing.lg),
              children: [
                Text('Modes', style: context.textTheme.titleMedium),
                const SizedBox(height: EcoSpacing.sm),
                ModeSwitcher(
                  modes: state.modes,
                  onSelect: (id) =>
                      context.read<AutomationCubit>().activateMode(id),
                ),
                const SizedBox(height: EcoSpacing.xl),
                _ListSection(
                  title: 'Schedules',
                  emptyMessage: 'No schedules yet',
                  items: [
                    for (final s in state.schedules)
                      _Row(title: s.name, subtitle: s.summary, enabled: s.enabled),
                  ],
                  onAdd: () => context.showSnack('Schedule editor — coming soon'),
                ),
                const SizedBox(height: EcoSpacing.xl),
                _ListSection(
                  title: 'Rules',
                  emptyMessage: 'No rules yet',
                  items: [
                    for (final r in state.rules)
                      _Row(title: r.name, subtitle: r.summary, enabled: r.enabled),
                  ],
                  onAdd: () => context.showSnack('Rule builder — coming soon'),
                ),
                const SizedBox(height: EcoSpacing.xl),
                Text('Budgets', style: context.textTheme.titleMedium),
                const SizedBox(height: EcoSpacing.sm),
                if (state.budgets.isEmpty)
                  const EmptyState(message: 'No budgets set')
                else
                  for (final b in state.budgets)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(EcoSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${b.period[0].toUpperCase()}${b.period.substring(1)} budget',
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: EcoSpacing.xs),
                            Text(
                              '${b.spent.formatted} of ${b.limit.formatted}',
                              style: context.textTheme.bodySmall,
                            ),
                            const SizedBox(height: EcoSpacing.sm),
                            LinearProgressIndicator(
                              value: b.progress,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: EcoSpacing.xs),
                            Text(
                              '${Formatters.percent(b.progress)} used · '
                              'warns at ${b.warnAtPct}%',
                              style: context.textTheme.labelMedium,
                            ),
                          ],
                        ),
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

class _ListSection extends StatelessWidget {
  const _ListSection({
    required this.title,
    required this.items,
    required this.emptyMessage,
    required this.onAdd,
  });
  final String title;
  final List<Widget> items;
  final String emptyMessage;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: context.textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        if (items.isEmpty)
          EmptyState(message: emptyMessage)
        else
          Card(child: Column(children: items)),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.enabled,
  });
  final String title;
  final String subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: enabled, onChanged: (_) {}),
    );
  }
}
