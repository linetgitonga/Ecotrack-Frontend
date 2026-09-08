import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../connectivity/presentation/widgets/connection_status_indicator.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(OtpRequested(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (p, c) => c is AuthFailure || c is OtpPending,
          listener: (context, state) {
            if (state is AuthFailure) context.showSnack(state.message);
            if (state is OtpPending) context.go(Routes.otp);
          },
          builder: (context, state) {
            final loading = state is OtpRequesting;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(EcoSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: ConnectionStatusIndicator(),
                  ),
                  const SizedBox(height: EcoSpacing.xxxl),
                  Icon(Icons.eco, size: 56, color: EcoColors.primary),
                  const SizedBox(height: EcoSpacing.lg),
                  Text(
                    'EcoTrack',
                    textAlign: TextAlign.center,
                    style: context.textTheme.displaySmall,
                  ),
                  const SizedBox(height: EcoSpacing.sm),
                  Text(
                    'Sign in with your phone number',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: EcoSpacing.xxl),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        hintText: '0712 345 678',
                        prefixText: '${AppConstants.phoneCountryCode}  ',
                      ),
                      validator: Validators.phone,
                      onFieldSubmitted: (_) => _submit(),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(height: EcoSpacing.xl),
                  FilledButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send code'),
                  ),
                  const SizedBox(height: EcoSpacing.lg),
                  Text(
                    "Don't have an account? Entering your number creates one, "
                    'or ask your building manager to add you.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(height: EcoSpacing.xxl),
                  _SecurityBadge(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          size: 14,
          color: context.colors.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: EcoSpacing.xs),
        Text(
          'SECURE · BANK-GRADE ENCRYPTION',
          style: context.textTheme.labelMedium?.copyWith(letterSpacing: 0.5),
        ),
      ],
    );
  }
}
