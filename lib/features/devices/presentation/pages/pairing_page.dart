import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../data/remote/api/tierb_api.dart';
import '../../../../injection/injection.dart';

class PairingPage extends StatefulWidget {
  const PairingPage({super.key});

  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  final _api = getIt<TierBApi>();
  Timer? _poll;
  bool _searching = false;
  String? _error;
  final _found = <CommissioningEntry>[];

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _searching = true;
      _error = null;
      _found.clear();
    });
    final hubs = await _api.hubs();
    final hubId =
        hubs.valueOrNull?.firstOrNull?['hub_id']?.toString() ?? 'hub-1';
    final opened = await _api.openPairing(hubId);
    if (opened.isErr) {
      setState(() {
        _searching = false;
        _error = opened.failureOrNull!.message;
      });
      return;
    }
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
  }

  Future<void> _tick() async {
    final r = await _api.commissioning();
    if (!mounted) return;
    r.when(
      ok: (entries) {
        setState(() {
          _found
            ..clear()
            ..addAll(entries);
        });
        if (entries.any((e) => e.isDone || e.isFailed)) {
          _poll?.cancel();
          setState(() => _searching = false);
        }
      },
      err: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a device')),
      body: ListView(
        padding: const EdgeInsets.all(EcoSpacing.lg),
        children: [
          Text(
            '1. Put your smart plug into pairing mode (usually hold the button '
            'for 5 seconds until it blinks).\n\n'
            '2. Tap "Start" — the hub will open its network for 2 minutes and '
            'look for new devices.',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: EcoSpacing.xl),
          if (_error != null)
            Text(_error!, style: TextStyle(color: context.colors.error)),
          if (!_searching && _found.isEmpty)
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Start pairing'),
            ),
          if (_searching)
            const Row(
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: EcoSpacing.md),
                Text('Searching for new devices…'),
              ],
            ),
          const SizedBox(height: EcoSpacing.lg),
          for (final e in _found)
            Card(
              child: ListTile(
                leading: Icon(
                  e.isDone
                      ? Icons.check_circle
                      : e.isFailed
                      ? Icons.error_outline
                      : Icons.sync,
                  color: e.isDone
                      ? EcoColors.success
                      : e.isFailed
                      ? EcoColors.error
                      : EcoColors.secondary,
                ),
                title: Text(e.name),
                subtitle: Text(_statusText(e.status)),
              ),
            ),
          if (_found.any((e) => e.isDone)) ...[
            const SizedBox(height: EcoSpacing.lg),
            FilledButton(
              onPressed: () => context.pop(true),
              child: const Text('Done'),
            ),
          ],
        ],
      ),
    );
  }

  String _statusText(String status) => switch (status) {
    'interviewing' => 'Interviewing the device…',
    'joined' => 'Joined — configuring…',
    'configured' => 'Ready to use',
    'failed' => 'Pairing failed — move it closer and retry',
    _ => 'Discovered',
  };
}
