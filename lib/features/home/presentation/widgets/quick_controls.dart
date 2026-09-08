import 'package:flutter/material.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/device.dart';
import '../../../../shared/widgets/eco_states.dart';

/// Grid of favourited appliances with toggle switches.
class QuickControls extends StatelessWidget {
  const QuickControls({
    super.key,
    required this.devices,
    required this.onToggle,
  });

  final List<Device> devices;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const EmptyState(
        icon: Icons.power_outlined,
        message: 'No controllable devices yet',
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 96,
        crossAxisSpacing: EcoSpacing.sm,
        mainAxisSpacing: EcoSpacing.sm,
      ),
      itemCount: devices.length,
      itemBuilder: (context, i) {
        final d = devices[i];
        return _DeviceTile(device: d, onToggle: () => onToggle(d.id));
      },
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.onToggle});
  final Device device;
  final VoidCallback onToggle;

  IconData get _icon => switch (device.deviceClass) {
    'light_node' => Icons.lightbulb_outline,
    'relay_module' => Icons.water_drop_outlined,
    'sensor' => Icons.sensors,
    _ => Icons.power_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = device.reachable && device.switchable;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, size: 18),
                const Spacer(),
                Semantics(
                  label: '${device.name}, ${device.statusLabel}',
                  child: Switch(
                    value: device.isOn,
                    onChanged: enabled ? (_) => onToggle() : null,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              device.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium,
            ),
            Text(
              device.reachable
                  ? (device.isOn ? Formatters.watts(device.watts) : 'Off')
                  : 'Unreachable',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
