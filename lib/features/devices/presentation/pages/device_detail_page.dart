import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_charts.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../bloc/device_detail_cubit.dart';

class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({super.key, required this.deviceId});
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeviceDetailCubit>()..load(deviceId),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<DeviceDetailCubit, DeviceDetailState>(
          buildWhen: (p, c) => p.device?.name != c.device?.name,
          builder: (_, s) => Text(s.device?.name ?? 'Device'),
        ),
      ),
      body: BlocConsumer<DeviceDetailCubit, DeviceDetailState>(
        listenWhen: (p, c) => c.error != null && p.error != c.error,
        listener: (context, s) => context.showSnack(s.error!),
        builder: (context, state) {
          if (state.loading && state.device == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = state.device;
          if (d == null) {
            return ErrorStateView(message: state.error ?? 'Device not found');
          }
          return ListView(
            padding: const EdgeInsets.all(EcoSpacing.lg),
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(
                      d.deviceClass == 'light_node'
                          ? Icons.lightbulb
                          : Icons.power,
                      size: 56,
                      color: d.isOn
                          ? EcoColors.primary
                          : context.colors.outline,
                    ),
                    const SizedBox(height: EcoSpacing.sm),
                    Text(d.statusLabel, style: context.textTheme.titleLarge),
                  ],
                ),
              ),
              const SizedBox(height: EcoSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(EcoSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Reading('Power', Formatters.watts(d.watts)),
                      _Reading(
                        'Voltage',
                        d.volts == null ? '—' : Formatters.volts(d.volts!),
                      ),
                      _Reading(
                        'Current',
                        d.amps == null ? '—' : Formatters.amps(d.amps!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: EcoSpacing.lg),
              if (d.switchable)
                Card(
                  child: SwitchListTile(
                    title: const Text('Power'),
                    subtitle: Text(
                      d.reachable
                          ? (d.isOn ? 'On' : 'Off')
                          : 'Unreachable — check the wall switch',
                    ),
                    value: d.isOn,
                    onChanged: state.busy || !d.reachable
                        ? null
                        : (_) => context.read<DeviceDetailCubit>().toggle(),
                  ),
                ),
              const SizedBox(height: EcoSpacing.lg),
              Text('Last 24 hours', style: context.textTheme.titleMedium),
              const SizedBox(height: EcoSpacing.sm),
              UsageLineChart(values: state.series, unitSuffix: ' W'),
              const SizedBox(height: EcoSpacing.lg),
              const _StubTile(
                icon: Icons.schedule,
                title: 'Schedules',
                subtitle: 'Set on/off times — coming soon',
              ),
              const _StubTile(
                icon: Icons.auto_mode,
                title: 'Automation',
                subtitle: 'Rules using this device — coming soon',
              ),
              _StubTile(
                icon: Icons.kitchen_outlined,
                title: 'Bound appliance',
                subtitle: d.roomName == null
                    ? 'Not assigned to a room'
                    : 'In ${d.roomName}',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Reading extends StatelessWidget {
  const _Reading(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: context.textTheme.titleMedium),
      Text(label, style: context.textTheme.labelMedium),
    ],
  );
}

class _StubTile extends StatelessWidget {
  const _StubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    ),
  );
}
