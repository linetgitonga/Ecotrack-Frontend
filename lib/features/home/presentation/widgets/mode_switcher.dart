import 'package:flutter/material.dart';

import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/device.dart';

/// Row of mode buttons (Eco · Home · Away · Night) with an active indicator.
class ModeSwitcher extends StatelessWidget {
  const ModeSwitcher({super.key, required this.modes, required this.onSelect});

  final List<EnergyMode> modes;
  final ValueChanged<String> onSelect;

  static const _icons = {
    'eco': Icons.eco,
    'home': Icons.home,
    'away': Icons.luggage_outlined,
    'night': Icons.nightlight_outlined,
    'comfort': Icons.chair_outlined,
    'sleep': Icons.bedtime_outlined,
  };

  @override
  Widget build(BuildContext context) {
    if (modes.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (final m in modes)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EcoSpacing.xs / 2,
              ),
              child: _ModeButton(
                label: m.name,
                icon: _icons[m.key] ?? Icons.tune,
                active: m.isActive,
                onTap: () => onSelect(m.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: '$label mode${active ? ', active' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EcoRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: EcoSpacing.md),
          decoration: BoxDecoration(
            color: active
                ? EcoColors.primary.withValues(alpha: 0.12)
                : context.colors.surface,
            border: Border.all(
              color: active ? EcoColors.primary : context.colors.outline,
              width: active ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(EcoRadii.md),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: active ? EcoColors.primary : context.colors.onSurface,
              ),
              const SizedBox(height: EcoSpacing.xs),
              Text(
                label,
                style: context.textTheme.labelMedium?.copyWith(
                  color: active ? EcoColors.primary : null,
                  fontWeight: active ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
