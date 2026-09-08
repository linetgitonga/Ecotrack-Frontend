import 'package:flutter/material.dart';

import '../../app/themes/spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';

/// Reusable OTP re-verification modal for step-up actions.
///
/// [initiate] sends the code; [verifyAndAct] verifies it and performs the
/// guarded action. Returns true when the action completed.
Future<bool> showStepUpDialog(
  BuildContext context, {
  required String title,
  required String actionLabel,
  required Future<Result<Unit>> Function() initiate,
  required Future<Result<Unit>> Function(String code) verifyAndAct,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _StepUpDialog(
      title: title,
      actionLabel: actionLabel,
      initiate: initiate,
      verifyAndAct: verifyAndAct,
    ),
  );
  return result ?? false;
}

class _StepUpDialog extends StatefulWidget {
  const _StepUpDialog({
    required this.title,
    required this.actionLabel,
    required this.initiate,
    required this.verifyAndAct,
  });

  final String title;
  final String actionLabel;
  final Future<Result<Unit>> Function() initiate;
  final Future<Result<Unit>> Function(String code) verifyAndAct;

  @override
  State<_StepUpDialog> createState() => _StepUpDialogState();
}

class _StepUpDialogState extends State<_StepUpDialog> {
  final _codeCtrl = TextEditingController();
  bool _sending = true;
  bool _working = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _send();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final r = await widget.initiate();
    if (!mounted) return;
    setState(() {
      _sending = false;
      _error = r.isErr ? _msg(r.failureOrNull!) : null;
    });
  }

  Future<void> _confirm() async {
    if (_codeCtrl.text.length != AppConstants.otpLength) return;
    setState(() {
      _working = true;
      _error = null;
    });
    final r = await widget.verifyAndAct(_codeCtrl.text.trim());
    if (!mounted) return;
    if (r.isOk) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _working = false;
      _error = _msg(r.failureOrNull!);
    });
  }

  String _msg(Failure f) => f is StepUpRequiredFailure
      ? 'That code was wrong or expired. Try again.'
      : f.message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter the ${AppConstants.otpLength}-digit code we just sent to '
            'your phone to confirm this action.',
          ),
          const SizedBox(height: EcoSpacing.lg),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: AppConstants.otpLength,
            enabled: !_sending && !_working,
            decoration: const InputDecoration(
              labelText: 'Verification code',
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(top: EcoSpacing.sm),
              child: Text('Sending code…'),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: EcoSpacing.sm),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _working ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: (_sending || _working) ? null : _send,
          child: const Text('Resend'),
        ),
        FilledButton(
          onPressed:
              (_sending ||
                  _working ||
                  _codeCtrl.text.length != AppConstants.otpLength)
              ? null
              : _confirm,
          child: _working
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.actionLabel),
        ),
      ],
    );
  }
}
