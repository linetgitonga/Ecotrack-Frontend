import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../connectivity/presentation/widgets/connection_status_indicator.dart';

/// Temporary landing screen after login. The real Home dashboard (live usage,
/// mode switcher, quick controls) lands in Phase 5 once the telemetry / device
/// repositories exist.
class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.user);
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoTrack'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: EcoSpacing.md),
            child: Center(child: ConnectionStatusIndicator()),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(EcoSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Signed in', style: context.textTheme.headlineSmall),
              const SizedBox(height: EcoSpacing.sm),
              if (user != null)
                Text(
                  '${user.name} · ${user.role.name}',
                  style: context.textTheme.bodyMedium,
                ),
              const SizedBox(height: EcoSpacing.xl),
              OutlinedButton.icon(
                onPressed: () =>
                    context.read<AuthBloc>().add(const LoggedOut()),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
