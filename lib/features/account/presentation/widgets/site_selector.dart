import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/site_bloc.dart';

/// Dropdown for multi-site users. Renders nothing when the user has 0–1 sites.
class SiteSelector extends StatelessWidget {
  const SiteSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteBloc, SiteState>(
      buildWhen: (p, c) =>
          p.sites != c.sites || p.selectedSiteId != c.selectedSiteId,
      builder: (context, state) {
        if (state.sites.length < 2) return const SizedBox.shrink();
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: state.selectedSite?.id,
            isDense: true,
            borderRadius: BorderRadius.circular(12),
            items: [
              for (final s in state.sites)
                DropdownMenuItem(value: s.id, child: Text(s.label)),
            ],
            onChanged: (id) {
              if (id != null) {
                context.read<SiteBloc>().add(SiteSelected(id));
              }
            },
          ),
        );
      },
    );
  }
}
