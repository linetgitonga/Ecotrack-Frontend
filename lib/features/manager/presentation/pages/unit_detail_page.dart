import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/remote/api/tierb_api.dart';
import '../../../../domain/entities/alert.dart';
import '../../../../domain/entities/device.dart';
import '../../../../injection/injection.dart';
import '../../../../shared/widgets/eco_states.dart';
import '../../../account/presentation/bloc/site_bloc.dart';

class UnitDetailPage extends StatefulWidget {
  const UnitDetailPage({super.key, required this.siteId});
  final String siteId;

  @override
  State<UnitDetailPage> createState() => _UnitDetailPageState();
}

class _UnitDetailPageState extends State<UnitDetailPage> {
  final _api = getIt<TierBApi>();
  bool _loading = true;
  LiveUsage? _usage;
  CostSummary? _cost;
  List<Device> _devices = const [];
  List<AlertEvent> _alerts = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await Future.wait([
      _api.summary(widget.siteId),
      _api.costSummary(widget.siteId),
      _api.devices(widget.siteId),
      _api.alerts(widget.siteId),
    ]);
    if (!mounted) return;
    setState(() {
      _usage = (r[0] as dynamic).valueOrNull as LiveUsage?;
      _cost = (r[1] as dynamic).valueOrNull as CostSummary?;
      _devices = (r[2] as dynamic).valueOrNull as List<Device>? ?? const [];
      _alerts = (r[3] as dynamic).valueOrNull as List<AlertEvent>? ?? const [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final site = context.read<SiteBloc>().state.sites.firstWhere(
          (s) => s.id == widget.siteId,
          orElse: () => throw StateError('site not found'),
        );
    final openAlerts =
        _alerts.where((a) => a.status == AlertStatus.open).toList();

    return Scaffold(
      appBar: AppBar(title: Text(site.label)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(EcoSpacing.lg),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(EcoSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Meter',
                              style: context.textTheme.labelMedium),
                          Text(
                            '${site.isPrepaid ? 'Prepaid' : 'Postpaid'} · '
                            '${site.supplyPhase} phase'
                            '${site.kplcMeterNo == null ? '' : ' · ${site.kplcMeterNo}'}',
                            style: context.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: EcoSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat('Live',
                            Formatters.watts(_usage?.liveWatts ?? 0)),
                      ),
                      Expanded(
                        child: _Stat(
                            'Today', Formatters.kwh(_usage?.todayKwh ?? 0)),
                      ),
                      Expanded(
                        child: _Stat(
                          'Month',
                          _cost?.monthToDate.formattedWithEstimate ?? '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: EcoSpacing.lg),
                  Text('Devices (${_devices.length})',
                      style: context.textTheme.titleMedium),
                  const SizedBox(height: EcoSpacing.sm),
                  for (final d in _devices.take(8))
                    Card(
                      child: ListTile(
                        dense: true,
                        title: Text(d.name),
                        subtitle: Text(d.statusLabel),
                        trailing: d.reachable && d.isOn
                            ? Text(Formatters.watts(d.watts))
                            : null,
                        onTap: () => context.push(Routes.device(d.id)),
                      ),
                    ),
                  const SizedBox(height: EcoSpacing.lg),
                  Text('Open alerts (${openAlerts.length})',
                      style: context.textTheme.titleMedium),
                  const SizedBox(height: EcoSpacing.sm),
                  if (openAlerts.isEmpty)
                    const EmptyState(message: 'No open alerts')
                  else
                    for (final a in openAlerts)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.warning_amber_outlined,
                            color: a.severity == AlertSeverity.critical
                                ? EcoColors.error
                                : EcoColors.warning,
                          ),
                          title: Text(a.title),
                          subtitle: Text(a.description),
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: context.textTheme.titleMedium),
          Text(label, style: context.textTheme.labelMedium),
        ],
      );
}
