extension EcoDateTime on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());

  /// Minutes since local midnight (0..1439) — the schedule storage unit.
  int get minutesSinceMidnight => hour * 60 + minute;

  /// Bit for this weekday in a `days_mask` (Mon=1 … Sun=64).
  int get weekdayBit => 1 << (weekday - 1);
}

extension EcoDuration on Duration {
  /// `"1h 5m"` / `"45s"` / `"3d"`.
  String get short {
    if (inDays > 0) return '${inDays}d';
    if (inHours > 0) {
      final m = inMinutes.remainder(60);
      return m == 0 ? '${inHours}h' : '${inHours}h ${m}m';
    }
    if (inMinutes > 0) return '${inMinutes}m';
    return '${inSeconds}s';
  }
}
