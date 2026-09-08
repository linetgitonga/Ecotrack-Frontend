/// Layout scale — 4pt grid. Use these instead of literal `EdgeInsets` numbers
/// so spacing stays consistent across screens.
abstract final class EcoSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radii.
abstract final class EcoRadii {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;
  static const double pill = 999;
}

/// Responsive breakpoints (width in logical px). See `context.breakpoint`.
enum Breakpoint { compact, medium, expanded }

abstract final class EcoBreakpoints {
  static const double medium = 600;
  static const double expanded = 1024;

  static Breakpoint of(double width) {
    if (width >= expanded) return Breakpoint.expanded;
    if (width >= medium) return Breakpoint.medium;
    return Breakpoint.compact;
  }
}
