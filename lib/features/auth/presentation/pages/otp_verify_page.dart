import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/otp_input.dart';

class OtpVerifyPage extends StatefulWidget {
  const OtpVerifyPage({super.key});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  String _code = '';
  Timer? _timer;
  int _secondsLeft = 0;
  int _lastNonce = -1;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = AppConstants.otpResendCooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onDigit(String d) {
    if (_code.length >= AppConstants.otpLength) return;
    setState(() => _code += d);
    if (_code.length == AppConstants.otpLength) {
      context.read<AuthBloc>().add(OtpSubmitted(_code));
    }
  }

  void _onBackspace() {
    if (_code.isEmpty) return;
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AuthBloc>().add(const OtpRestarted());
            context.go(Routes.login);
          },
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              c is AuthFailure || c is Authenticated || c is OtpPending,
          listener: (context, state) {
            if (state is AuthFailure) {
              context.showSnack(state.message);
              setState(() => _code = '');
            }
            if (state is OtpPending && state.resendNonce != _lastNonce) {
              _lastNonce = state.resendNonce;
              _startCountdown();
              context.showSnack('A new code has been sent.');
            }
          },
          builder: (context, state) {
            final pending = _pendingOf(state);
            final verifying = state is OtpVerifying;
            return Padding(
              padding: const EdgeInsets.all(EcoSpacing.xl),
              child: Column(
                children: [
                  Text(
                    'Enter the code',
                    style: context.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: EcoSpacing.sm),
                  Text(
                    pending == null
                        ? 'We sent a 6-digit code to your phone'
                        : 'Sent to ${pending.challenge.maskedTarget}',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: EcoSpacing.xl),
                  OtpCells(value: _code),
                  const SizedBox(height: EcoSpacing.md),
                  if (verifying)
                    const Padding(
                      padding: EdgeInsets.all(EcoSpacing.sm),
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _secondsLeft > 0
                          ? null
                          : () => context.read<AuthBloc>().add(
                              const OtpResendRequested(),
                            ),
                      child: Text(
                        _secondsLeft > 0
                            ? 'Resend code in ${_secondsLeft}s'
                            : 'Resend code',
                      ),
                    ),
                  const Spacer(),
                  OtpKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
                  const SizedBox(height: EcoSpacing.sm),
                  FilledButton(
                    onPressed:
                        _code.length == AppConstants.otpLength && !verifying
                        ? () =>
                              context.read<AuthBloc>().add(OtpSubmitted(_code))
                        : null,
                    child: const Text('Verify'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  OtpPending? _pendingOf(AuthState s) => switch (s) {
    OtpPending() => s,
    AuthFailure(:final previous) when previous is OtpPending => previous,
    _ => null,
  };
}
