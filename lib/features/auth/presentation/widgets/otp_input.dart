import 'package:flutter/material.dart';

import '../../../../app/themes/colors.dart';
import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Read-only 6-cell display of the current code (input comes from the keypad).
class OtpCells extends StatelessWidget {
  const OtpCells({super.key, required this.value, this.length = 6});

  final String value;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final filled = i < value.length;
        final active = i == value.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: EcoSpacing.xs),
          width: 44,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(EcoRadii.md),
            border: Border.all(
              color: active ? EcoColors.primary : context.colors.outline,
              width: active ? 2 : 1,
            ),
          ),
          child: Text(
            filled ? value[i] : '',
            style: context.textTheme.headlineSmall,
          ),
        );
      }),
    );
  }
}

/// Numeric keypad with the letter groups from the wireframe. Emits digits and
/// backspace; the page owns the code string.
class OtpKeypad extends StatelessWidget {
  const OtpKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  static const _letters = {
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ',
  };

  @override
  Widget build(BuildContext context) {
    final keys = [
      ...['1', '2', '3', '4', '5', '6', '7', '8', '9'],
      '',
      '0',
      '<',
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.7,
      children: keys.map((k) {
        if (k.isEmpty) return const SizedBox.shrink();
        if (k == '<') {
          return _Key(
            semanticLabel: 'Delete',
            onTap: onBackspace,
            child: const Icon(Icons.backspace_outlined),
          );
        }
        return _Key(
          semanticLabel: 'Digit $k',
          onTap: () => onDigit(k),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(k, style: context.textTheme.headlineSmall),
              if (_letters[k] != null)
                Text(_letters[k]!, style: context.textTheme.labelMedium),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.child,
    required this.onTap,
    required this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EcoRadii.md),
        child: Center(child: child),
      ),
    );
  }
}
