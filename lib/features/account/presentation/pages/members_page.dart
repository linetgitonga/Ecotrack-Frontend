import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/site.dart';
import '../../../../domain/value_objects/role.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../../../../shared/widgets/step_up_dialog.dart';
import '../bloc/members_cubit.dart';
import '../bloc/site_bloc.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key, required this.siteId});
  final String siteId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MembersCubit>()..subscribe(siteId),
      child: _MembersView(siteId: siteId),
    );
  }
}

class _MembersView extends StatelessWidget {
  const _MembersView({required this.siteId});
  final String siteId;

  bool _canManage(BuildContext context) {
    final role = context.read<SiteBloc>().effectiveRole;
    return role == Role.owner;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      floatingActionButton: _canManage(context)
          ? FloatingActionButton.extended(
              onPressed: () => _invite(context),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Invite'),
            )
          : null,
      body: BlocConsumer<MembersCubit, MembersState>(
        listenWhen: (p, c) => p.error != c.error && c.error != null,
        listener: (context, state) => context.showSnack(state.error!),
        builder: (context, state) {
          if (state.loading && state.members.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.members.isEmpty) {
            return const EmptyState(
              icon: Icons.group_outlined,
              message: 'No members on this site yet',
            );
          }
          final canManage = _canManage(context);
          return ListView.separated(
            padding: const EdgeInsets.all(EcoSpacing.lg),
            itemCount: state.members.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = state.members[i];
              final busy = state.busyUserId == m.userId;
              return ListTile(
                leading: CircleAvatar(child: Text(m.name.characters.first)),
                title: Text(m.name),
                subtitle: Text(m.phoneE164 ?? ''),
                trailing: busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : canManage
                    ? _MemberMenu(member: m)
                    : Chip(
                        label: Text(m.role),
                        visualDensity: VisualDensity.compact,
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _invite(BuildContext context) async {
    final cubit = context.read<MembersCubit>();
    final phoneCtrl = TextEditingController();
    var role = 'member';
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Invite a member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixText: '${AppConstants.phoneCountryCode}  ',
                ),
              ),
              const SizedBox(height: EcoSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'member', child: Text('Member')),
                  DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                  DropdownMenuItem(
                    value: 'installer',
                    child: Text('Installer'),
                  ),
                  DropdownMenuItem(value: 'owner', child: Text('Owner')),
                ],
                onChanged: (v) => setState(() => role = v ?? 'member'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Send invite'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;

    final normalized = Validators.normalizePhone(phoneCtrl.text);
    if (normalized == null) {
      context.showSnack('Enter a valid phone number');
      return;
    }
    final r = await cubit.invite(phoneE164: normalized, role: role);
    if (!context.mounted) return;
    r.when(
      ok: (_) => context.showSnack('Invite sent'),
      err: (f) => context.showSnack(f.message),
    );
  }
}

class _MemberMenu extends StatelessWidget {
  const _MemberMenu({required this.member});
  final SiteMember member;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) async {
        final cubit = context.read<MembersCubit>();
        if (v == 'remove') {
          final done = await showStepUpDialog(
            context,
            title: 'Remove ${member.name}?',
            actionLabel: 'Remove',
            initiate: cubit.beginRemove,
            verifyAndAct: (code) => cubit.confirmRemove(member.userId, code),
          );
          if (done && context.mounted) context.showSnack('Member removed');
        } else {
          await cubit.changeRole(member.userId, v);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'owner', child: Text('Set as owner')),
        const PopupMenuItem(value: 'member', child: Text('Set as member')),
        const PopupMenuItem(value: 'viewer', child: Text('Set as viewer')),
        const PopupMenuItem(
          value: 'installer',
          child: Text('Set as installer'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'remove', child: Text('Remove from site')),
      ],
    );
  }
}
