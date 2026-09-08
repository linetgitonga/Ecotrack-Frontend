import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/device.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../../../account/presentation/bloc/site_bloc.dart';
import '../../../connectivity/presentation/widgets/connection_status_indicator.dart';
import '../bloc/device_list_cubit.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<DeviceListCubit>();
        final siteId = context.read<SiteBloc>().state.selectedSiteId;
        if (siteId != null) cubit.subscribe(siteId);
        return cubit;
      },
      child: const _DevicesView(),
    );
  }
}

class _DevicesView extends StatelessWidget {
  const _DevicesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: EcoSpacing.md),
            child: Center(child: ConnectionStatusIndicator()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await context.push<bool>('${Routes.devices}/add');
          if (added == true && context.mounted) {
            context.read<DeviceListCubit>().load();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add device'),
      ),
      body: BlocConsumer<DeviceListCubit, DeviceListState>(
        listenWhen: (p, c) => c.error != null && p.error != c.error,
        listener: (context, state) => context.showSnack(state.error!),
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  EcoSpacing.lg,
                  EcoSpacing.sm,
                  EcoSpacing.lg,
                  0,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search devices',
                    isDense: true,
                  ),
                  onChanged: context.read<DeviceListCubit>().setQuery,
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: EcoSpacing.lg,
                  ),
                  children: [
                    for (final f in DeviceFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: EcoSpacing.sm),
                        child: ChoiceChip(
                          label: Text(_filterLabel(f)),
                          selected: state.filter == f,
                          onSelected: (_) =>
                              context.read<DeviceListCubit>().setFilter(f),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: state.loading && state.devices.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.visible.isEmpty
                    ? const EmptyState(
                        icon: Icons.devices_other_outlined,
                        message: 'No devices match',
                      )
                    : RefreshIndicator(
                        onRefresh: () => context.read<DeviceListCubit>().load(),
                        child: _GroupedList(state: state),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _filterLabel(DeviceFilter f) => switch (f) {
    DeviceFilter.all => 'All',
    DeviceFilter.online => 'Online',
    DeviceFilter.critical => 'Critical',
  };
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.state});
  final DeviceListState state;

  @override
  Widget build(BuildContext context) {
    final groups = state.byRoom.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(EcoSpacing.lg),
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final group = groups[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: EcoSpacing.sm),
              child: Text(group.key, style: context.textTheme.titleMedium),
            ),
            for (final d in group.value)
              _DeviceRow(
                device: d,
                busy: state.busyIds.contains(d.id),
                onToggle: () => context.read<DeviceListCubit>().toggle(d.id),
              ),
            const SizedBox(height: EcoSpacing.md),
          ],
        );
      },
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.device,
    required this.busy,
    required this.onToggle,
  });
  final Device device;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          device.deviceClass == 'light_node'
              ? Icons.lightbulb_outline
              : Icons.power_outlined,
        ),
        title: Text(device.name),
        subtitle: Text(
          [
            device.statusLabel,
            if (device.reachable && device.isOn) Formatters.watts(device.watts),
            if (device.lastSeenAt != null)
              Formatters.relative(device.lastSeenAt!),
          ].join(' · '),
        ),
        trailing: busy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Switch(
                value: device.isOn,
                onChanged: device.reachable && device.switchable
                    ? (_) => onToggle()
                    : null,
              ),
        onTap: () => context.push(Routes.device(device.id)),
      ),
    );
  }
}
