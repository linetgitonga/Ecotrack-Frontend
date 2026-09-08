import 'package:flutter/material.dart';

import '../../app/themes/spacing.dart';

extension EcoBuildContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  MediaQueryData get media => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// Responsive breakpoint for the current width.
  Breakpoint get breakpoint => EcoBreakpoints.of(MediaQuery.sizeOf(this).width);
  bool get isCompact => breakpoint == Breakpoint.compact;
  bool get isExpanded => breakpoint == Breakpoint.expanded;

  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
