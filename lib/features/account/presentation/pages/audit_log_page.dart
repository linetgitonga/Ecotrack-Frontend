import 'package:flutter/material.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/remote/api/audit_api.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_states.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  final _api = getIt<AuditApi>();
  final _items = <AuditEntry>[];
  final _scroll = ScrollController();
  String? _cursor;
  bool _loading = false;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading || _done) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await _api.list(cursor: _cursor);
    if (!mounted) return;
    r.when(
      ok: (page) => setState(() {
        _items.addAll(page.items);
        _cursor = page.nextCursor;
        _done = page.nextCursor == null;
        _loading = false;
      }),
      err: (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity log')),
      body: _items.isEmpty && _error != null
          ? ErrorStateView(message: _error!, onRetry: _load)
          : _items.isEmpty && _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              message: 'No recorded activity yet',
            )
          : ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.all(EcoSpacing.lg),
              itemCount: _items.length + (_done ? 0 : 1),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                if (i >= _items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(EcoSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final e = _items[i];
                return ListTile(
                  dense: true,
                  leading: _icon(e.category),
                  title: Text(e.actionType),
                  subtitle: Text(
                    [
                      e.entity,
                      if (e.createdAt != null)
                        Formatters.relative(e.createdAt!),
                    ].whereType<String>().join(' · '),
                  ),
                );
              },
            ),
    );
  }

  Widget _icon(String category) {
    final data = switch (category) {
      'auth' => Icons.login,
      'authz' => Icons.shield_outlined,
      'billing' => Icons.receipt_long_outlined,
      'device' => Icons.devices_other,
      'security' => Icons.gpp_maybe_outlined,
      _ => Icons.settings_outlined,
    };
    return Icon(data, size: 20, color: context.colors.onSurfaceVariant);
  }
}
