import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/value_objects/role.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../bloc/site_bloc.dart';

class SitesPage extends StatelessWidget {
  const SitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sites')),
      floatingActionButton: BlocBuilder<SiteBloc, SiteState>(
        buildWhen: (p, c) => false,
        builder: (context, _) {
          final canAdd = context.read<SiteBloc>().tenantRole.can(
            Permission.manageSiteSettings,
          );
          if (!canAdd) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => context.push('${Routes.accountSites}/new'),
            icon: const Icon(Icons.add),
            label: const Text('Add site'),
          );
        },
      ),
      body: BlocBuilder<SiteBloc, SiteState>(
        builder: (context, state) {
          if (state.status == SiteStatus.loading && state.sites.isEmpty) {
            return const _SitesLoading();
          }
          if (state.status == SiteStatus.error && state.sites.isEmpty) {
            return ErrorStateView(
              message: state.error ?? 'Could not load your sites',
              onRetry: () =>
                  context.read<SiteBloc>().add(const SitesRefreshed()),
            );
          }
          if (state.sites.isEmpty) {
            return const EmptyState(
              icon: Icons.home_work_outlined,
              message: 'No sites yet',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<SiteBloc>().add(const SitesRefreshed()),
            child: ListView.separated(
              padding: const EdgeInsets.all(EcoSpacing.lg),
              itemCount: state.sites.length,
              separatorBuilder: (_, _) => const SizedBox(height: EcoSpacing.sm),
              itemBuilder: (context, i) {
                final site = state.sites[i];
                final selected = site.id == state.selectedSiteId;
                return Card(
                  child: ListTile(
                    leading: Icon(
                      selected ? Icons.check_circle : Icons.home_outlined,
                      color: selected ? context.colors.primary : null,
                    ),
                    title: Text(site.label),
                    subtitle: Text(
                      '${site.isPrepaid ? 'Prepaid' : 'Postpaid'} · '
                      '${site.supplyPhase} phase · ${site.status}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'select') {
                          context.read<SiteBloc>().add(SiteSelected(site.id));
                        } else if (v == 'members') {
                          context.push(Routes.siteMembers(site.id));
                        } else if (v == 'edit') {
                          context.push(
                            '${Routes.accountSites}/${site.id}/edit',
                          );
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'select',
                          child: Text('Make active'),
                        ),
                        PopupMenuItem(value: 'members', child: Text('Members')),
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                      ],
                    ),
                    onTap: () =>
                        context.read<SiteBloc>().add(SiteSelected(site.id)),
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

class _SitesLoading extends StatelessWidget {
  const _SitesLoading();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(EcoSpacing.lg),
    children: const [
      LoadingShimmer(),
      SizedBox(height: EcoSpacing.sm),
      LoadingShimmer(),
      SizedBox(height: EcoSpacing.sm),
      LoadingShimmer(),
    ],
  );
}
