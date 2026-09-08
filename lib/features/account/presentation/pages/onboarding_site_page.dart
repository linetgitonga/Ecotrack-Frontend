import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/site_bloc.dart';

/// Shown after login when the account has zero sites.
class OnboardingSitePage extends StatefulWidget {
  const OnboardingSitePage({super.key});

  @override
  State<OnboardingSitePage> createState() => _OnboardingSitePageState();
}

class _OnboardingSitePageState extends State<OnboardingSitePage> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController(text: 'My Home');
  String _meterType = 'prepaid';
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    context.read<SiteBloc>().add(
      SiteCreated({'label': _label.text.trim(), 'meter_type': _meterType}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SiteBloc, SiteState>(
      listenWhen: (p, c) => c.sites.isNotEmpty || c.error != null,
      listener: (context, state) {
        if (state.sites.isNotEmpty) {
          context.go(Routes.home);
        } else if (state.error != null) {
          setState(() => _saving = false);
          context.showSnack(state.error!);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Set up your first site')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(EcoSpacing.xl),
            children: [
              Text(
                'A site is a home or premises with a KPLC meter. You can add '
                'more later.',
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: EcoSpacing.xl),
              TextFormField(
                controller: _label,
                decoration: const InputDecoration(labelText: 'Site name'),
                validator: (v) => Validators.notEmpty(v, field: 'Site name'),
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
              const SizedBox(height: EcoSpacing.xl),
              FilledButton(
                onPressed: _saving ? null : _create,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create site'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
