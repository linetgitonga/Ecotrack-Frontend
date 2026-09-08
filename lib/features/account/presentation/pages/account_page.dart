import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../connectivity/presentation/widgets/connection_status_indicator.dart';
import '../bloc/site_bloc.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.user);
    final siteCount = context.select((SiteBloc b) => b.state.sites.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: EcoSpacing.md),
            child: Center(child: ConnectionStatusIndicator()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(EcoSpacing.lg),
        children: [
          _ProfileCard(
            name: user?.name ?? '—',
            phone: user?.phone.national ?? '',
            role: user?.role.name ?? '',
            email: user?.email,
            onEdit: () => context.push(Routes.preferences),
          ),
          const SizedBox(height: EcoSpacing.lg),
          _SectionCard(
            children: [
              _Tile(
                icon: Icons.home_work_outlined,
                title: 'Sites',
                subtitle: '$siteCount site${siteCount == 1 ? '' : 's'}',
                onTap: () => context.push(Routes.accountSites),
              ),
              _Tile(
                icon: Icons.devices_outlined,
                title: 'Active sessions',
                subtitle: 'Devices signed in to your account',
                onTap: () => context.push(Routes.sessions),
              ),
              _Tile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy & data',
                subtitle: 'Consents, download or delete your data',
                onTap: () => context.push(Routes.privacy),
              ),
              _Tile(
                icon: Icons.history,
                title: 'Activity log',
                subtitle: 'Recent changes on your account',
                onTap: () => context.push('${Routes.account}/audit'),
              ),
            ],
          ),
          const SizedBox(height: EcoSpacing.lg),
          _SectionCard(
            children: [
              _Tile(
                icon: Icons.logout,
                title: 'Sign out',
                onTap: () => context.read<AuthBloc>().add(const LoggedOut()),
              ),
              _Tile(
                icon: Icons.gpp_bad_outlined,
                title: 'Sign out everywhere',
                subtitle: 'Ends every session on all devices',
                destructive: true,
                onTap: () => _confirmSignOutAll(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOutAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out everywhere?'),
        content: const Text(
          'This ends your session on every device, including this one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out everywhere'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AuthBloc>().add(const LoggedOut(everywhere: true));
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.phone,
    required this.role,
    required this.onEdit,
    this.email,
  });

  final String name;
  final String phone;
  final String role;
  final String? email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcoSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              child: Text(name.isNotEmpty ? name.characters.first : '?'),
            ),
            const SizedBox(width: EcoSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: context.textTheme.titleMedium),
                  Text(phone, style: context.textTheme.bodySmall),
                  if (email != null && email!.isNotEmpty)
                    Text(email!, style: context.textTheme.bodySmall),
                  const SizedBox(height: EcoSpacing.xs),
                  Chip(
                    label: Text(role),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit profile & preferences',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? context.colors.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
