import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Profile + preferences. Backend only allows `display_name` and `locale`
/// (backend_design.md §3.2); the rest of `user_preferences` is Tier B (Phase 5).
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late String _locale;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().user;
    _name = TextEditingController(text: user?.displayName ?? '');
    _locale = user?.locale ?? 'en-KE';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    final r = await getIt<AuthRepository>().updateProfile(
      displayName: _name.text.trim(),
      locale: _locale,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    r.when(
      ok: (_) {
        context.read<AuthBloc>().add(const AuthProfileReloaded());
        context.showSnack('Profile updated');
        context.pop();
      },
      err: (f) => context.showSnack(f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & preferences')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(EcoSpacing.lg),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Display name'),
              validator: (v) => Validators.notEmpty(v, field: 'Name'),
            ),
            const SizedBox(height: EcoSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _locale,
              decoration: const InputDecoration(labelText: 'Language'),
              items: const [
                DropdownMenuItem(value: 'en-KE', child: Text('English')),
                DropdownMenuItem(value: 'sw-KE', child: Text('Kiswahili')),
              ],
              onChanged: (v) => setState(() => _locale = v ?? 'en-KE'),
            ),
            const SizedBox(height: EcoSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
