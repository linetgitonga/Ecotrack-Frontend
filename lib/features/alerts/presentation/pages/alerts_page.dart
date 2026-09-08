import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/alert.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../../../account/presentation/bloc/site_bloc.dart';
import '../bloc/alerts_cubit.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final c = getIt<AlertsCubit>();
        final s = context.read<SiteBloc>().state.selectedSiteId;
        if (s != null) c.load(s);
        return c;
      },
      child: const _AlertsView(),
    );
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView();

  @override
  Widget build(BuildContext context) {
    final siteId = context.select((SiteBloc b) => b.state.selectedSiteId);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alerts'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Open'),
              Tab(text: 'Acknowledged'),
              Tab(text: 'Closed'),
            ],
          ),
        ),
        body: BlocConsumer<AlertsCubit, AlertsState>(
          listenWhen: (p, c) => c.error != null && p.error != c.error,
          listener: (context, state) => context.showSnack(state.error!),
          builder: (context, state) {
            if (state.loading && state.alerts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: () async => siteId != null
                  ? context.read<AlertsCubit>().load(siteId)
                  : null,
              child: TabBarView(
                children: [
                  _AlertList(
                    items: state.byStatus(AlertStatus.open),
                    state: state,
                  ),
                  _AlertList(
                    items: state.byStatus(AlertStatus.acknowledged),
                    state: state,
                  ),
                  _AlertList(
                    items: state.byStatus(AlertStatus.closed),
                    state: state,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList({required this.items, required this.state});
  final List<AlertEvent> items;
  final AlertsState state;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          EmptyState(icon: Icons.notifications_none, message: 'Nothing here'),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(EcoSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: EcoSpacing.sm),
      itemBuilder: (context, i) =>
          _AlertCard(alert: items[i], busy: state.busyId == items[i].id),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.busy});
  final AlertEvent alert;
  final bool busy;

  (Color, IconData) get _visual => switch (alert.severity) {
    AlertSeverity.critical => (EcoColors.error, Icons.error_outline),
    AlertSeverity.warning => (EcoColors.warning, Icons.warning_amber_outlined),
    AlertSeverity.info => (EcoColors.info, Icons.info_outline),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _visual;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcoSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: EcoSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title, style: context.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(alert.description, style: context.textTheme.bodySmall),
                  const SizedBox(height: EcoSpacing.xs),
                  Text(
                    '${alert.severity.name} · ${Formatters.relative(alert.openedAt)}',
                    style: context.textTheme.labelMedium,
                  ),
                  if (alert.status == AlertStatus.open) ...[
                    const SizedBox(height: EcoSpacing.sm),
                    FilledButton.tonal(
                      onPressed: busy
                          ? null
                          : () => context.read<AlertsCubit>().acknowledge(
                              alert.id,
                            ),
                      child: busy
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Acknowledge'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
