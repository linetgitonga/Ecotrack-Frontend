import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/step_up_dialog.dart';
import '../bloc/consent_cubit.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConsentCubit>()..load(),
      child: const _PrivacyView(),
    );
  }
}

class _PrivacyView extends StatelessWidget {
  const _PrivacyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & data')),
      body: BlocConsumer<ConsentCubit, ConsentState>(
        listenWhen: (p, c) =>
            (c.error != null && p.error != c.error) ||
            (c.requestResult != null && p.requestResult != c.requestResult),
        listener: (context, state) {
          if (state.error != null) context.showSnack(state.error!);
          if (state.requestResult != null) {
            showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Request received'),
                content: Text(state.requestResult!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.loading && state.granted.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(EcoSpacing.lg),
            children: [
              Text(
                'EcoTrack processes personal data under the Kenya Data '
                'Protection Act 2019. Household energy data can reveal when '
                'your home is occupied, so you control how it is used.',
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: EcoSpacing.lg),
              Text('What you allow', style: context.textTheme.titleMedium),
              const SizedBox(height: EcoSpacing.sm),
              Card(
                child: Column(
                  children: [
                    for (final p in ConsentPurpose.values)
                      SwitchListTile(
                        title: Text(p.label),
                        subtitle: Text(p.description),
                        value: state.isGranted(p),
                        onChanged: p.required || state.saving == p.key
                            ? null
                            : (v) =>
                                  context.read<ConsentCubit>().setConsent(p, v),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: EcoSpacing.lg),
              Text('Policies', style: context.textTheme.titleMedium),
              const SizedBox(height: EcoSpacing.sm),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.shield_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/account/privacy/policy'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/account/privacy/terms'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: EcoSpacing.lg),
              Text('Your data rights', style: context.textTheme.titleMedium),
              const SizedBox(height: EcoSpacing.sm),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Download my data'),
                      subtitle: const Text(
                        'A copy of your account and energy data, by email',
                      ),
                      onTap: () => context.read<ConsentCubit>().requestExport(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever_outlined,
                        color: context.colors.error,
                      ),
                      title: Text(
                        'Delete my account & data',
                        style: TextStyle(color: context.colors.error),
                      ),
                      subtitle: const Text(
                        'Requires verification. Irreversible.',
                      ),
                      onTap: () => _confirmErasure(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmErasure(BuildContext context) async {
    final cubit = context.read<ConsentCubit>();
    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'This permanently deletes your EcoTrack account and all associated '
          'data. Your hub will need to be re-claimed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;

    await showStepUpDialog(
      context,
      title: 'Confirm account deletion',
      actionLabel: 'Delete account',
      initiate: cubit.beginErasure,
      verifyAndAct: cubit.confirmErasure,
    );
  }
}
