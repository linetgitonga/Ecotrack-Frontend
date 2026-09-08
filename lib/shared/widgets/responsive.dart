import 'package:flutter/widgets.dart';

import '../../core/extensions/context_extensions.dart';

/// Centres content and caps its width on large screens so the web dashboard
/// doesn't stretch list content edge to edge. A no-op below [maxWidth].
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({super.key, required this.child, this.maxWidth = 900});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (context.screenSize.width <= maxWidth) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// True when a data-dense table layout is appropriate (wide screen).
bool useTableLayout(BuildContext context) => context.isExpanded;
