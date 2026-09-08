import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/sessions_cubit.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SessionsCubit>()..load(),
      child: const _SessionsView(),
    );
  }
}

class _SessionsView extends StatelessWidget {
  const _SessionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active sessions'),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<AuthBloc>().add(const LoggedOut(everywhere: true)),
            child: const Text('End all'),
          ),
        ],
      ),
      body: BlocConsumer<SessionsCubit, SessionsState>(
        listenWhen: (p, c) => p.error != c.error && c.error != null,
        listener: (context, state) => context.showSnack(state.error!),
        builder: (context, state) {
          if (state.loading && state.sessions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.sessions.isEmpty) {
            return ErrorStateView(
              message: state.error!,
              onRetry: () => context.read<SessionsCubit>().load(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<SessionsCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(EcoSpacing.lg),
              itemCount: state.sessions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = state.sessions[i];
                return ListTile(
                  leading: Icon(
                    s.isCurrent ? Icons.smartphone : Icons.devices_other,
                  ),
                  title: Text(s.label + (s.isCurrent ? '  (this device)' : '')),
                  subtitle: Text(
                    [
                      if (s.ipAddress != null) s.ipAddress!,
                      if (s.lastActivity != null)
                        'active ${Formatters.relative(s.lastActivity!)}',
                    ].join(' · '),
                  ),
                  trailing: s.isCurrent
                      ? null
                      : IconButton(
                          tooltip: 'End this session',
                          icon: const Icon(Icons.logout),
                          onPressed: () async {
                            final r = await context
                                .read<SessionsCubit>()
                                .revoke(s.id);
                            if (context.mounted && r.isErr) {
                              context.showSnack(r.failureOrNull!.message);
                            }
                          },
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
