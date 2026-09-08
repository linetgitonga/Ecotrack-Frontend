import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/connectivity/connection_state.dart';
import '../../../../core/utils/formatters.dart';
import '../bloc/connectivity_bloc.dart';

/// Always-visible LAN / Cloud / Offline badge (brief "Key Behaviors" §1).
/// Status is conveyed by icon + text, never colour alone (accessibility).
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key, this.compact = true});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        final c = state.connection;
        final (color, icon, label) = _present(c);
        final semantics = 'Connection: $label';

        return Semantics(
          label: semantics,
          button: !c.mode.isOnline,
          child: InkWell(
            onTap: c.mode.isOnline
                ? null
                : () => context.read<ConnectivityBloc>().add(
                    const ConnectivityProbeRequested(),
                  ),
            borderRadius: BorderRadius.circular(EcoRadii.pill),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: EcoSpacing.md,
                vertical: EcoSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(EcoRadii.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: EcoSpacing.xs),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  (Color, IconData, String) _present(EcoConnection c) {
    switch (c.mode) {
      case ConnectionMode.lan:
        return (EcoColors.lanMode, Icons.wifi_tethering, 'On home network');
      case ConnectionMode.cloud:
        return (EcoColors.cloudMode, Icons.cloud_done_outlined, 'Remote');
      case ConnectionMode.cloudHubOffline:
        return (EcoColors.cloudMode, Icons.cloud_off_outlined, 'Hub offline');
      case ConnectionMode.offline:
        final suffix = c.lastDataAt == null
            ? ''
            : ' · ${Formatters.lastUpdated(c.lastDataAt!)}';
        return (EcoColors.offlineMode, Icons.cloud_off, 'Offline$suffix');
    }
  }
}
