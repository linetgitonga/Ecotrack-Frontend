import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/site_bloc.dart';

/// Create (no [siteId]) or edit an existing site.
class SiteFormPage extends StatefulWidget {
  const SiteFormPage({super.key, this.siteId});
  final String? siteId;

  @override
  State<SiteFormPage> createState() => _SiteFormPageState();
}

class _SiteFormPageState extends State<SiteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _meterNo = TextEditingController();
  final _accountNo = TextEditingController();
  String _meterType = 'prepaid';
  String _phase = 'single';
  bool _saving = false;

  bool get _isEdit => widget.siteId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final site = context.read<SiteBloc>().state.sites.firstWhere(
        (s) => s.id == widget.siteId,
        orElse: () => throw StateError('site not in list'),
      );
      _label.text = site.label;
      _meterNo.text = site.kplcMeterNo ?? '';
      _accountNo.text = site.kplcAccountNo ?? '';
      _meterType = site.isPrepaid ? 'prepaid' : 'postpaid';
      _phase = site.supplyPhase;
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _meterNo.dispose();
    _accountNo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);

    final body = <String, dynamic>{
      'label': _label.text.trim(),
      'meter_type': _meterType,
      'supply_phase': _phase,
      if (_meterNo.text.trim().isNotEmpty)
        'kplc_meter_no': _meterNo.text.trim(),
      if (_accountNo.text.trim().isNotEmpty)
        'kplc_account_no': _accountNo.text.trim(),
    };

    final bloc = context.read<SiteBloc>();
    if (_isEdit) {
      bloc.add(SiteUpdated(widget.siteId!, body));
    } else {
      bloc.add(SiteCreated(body));
    }
    // The bloc emits saving→loaded; wait a beat then pop.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit site' : 'Add site')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(EcoSpacing.lg),
          children: [
            TextFormField(
              controller: _label,
              decoration: const InputDecoration(labelText: 'Site name'),
              validator: (v) => Validators.notEmpty(v, field: 'Site name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: EcoSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _meterType,
              decoration: const InputDecoration(labelText: 'Meter type'),
              items: const [
                DropdownMenuItem(value: 'prepaid', child: Text('Prepaid')),
                DropdownMenuItem(value: 'postpaid', child: Text('Postpaid')),
              ],
              onChanged: (v) => setState(() => _meterType = v ?? 'prepaid'),
            ),
            const SizedBox(height: EcoSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _phase,
              decoration: const InputDecoration(labelText: 'Supply phase'),
              items: const [
                DropdownMenuItem(value: 'single', child: Text('Single phase')),
                DropdownMenuItem(value: 'three', child: Text('Three phase')),
              ],
              onChanged: (v) => setState(() => _phase = v ?? 'single'),
            ),
            const SizedBox(height: EcoSpacing.lg),
            TextFormField(
              controller: _meterNo,
              decoration: const InputDecoration(
                labelText: 'KPLC meter number (optional)',
              ),
              validator: Validators.kplcMeterNo,
            ),
            const SizedBox(height: EcoSpacing.lg),
            TextFormField(
              controller: _accountNo,
              decoration: const InputDecoration(
                labelText: 'KPLC account number (optional)',
              ),
            ),
            const SizedBox(height: EcoSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEdit ? 'Save changes' : 'Create site'),
            ),
          ],
        ),
      ),
    );
  }
}
