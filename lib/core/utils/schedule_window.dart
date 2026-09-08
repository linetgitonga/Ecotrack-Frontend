/// Normative schedule-window semantics, shared by schedules, `time_between` rule
/// conditions, and quiet hours (System_Design §7 / Database_Design §1.6).
///
///   * `start < end`  → same-day interval `[start, end)`
///   * `start > end`  → wraps past midnight: `[start, 24:00) ∪ [00:00, end)`
///   * `start == end` → rejected (degenerate zero-length window)
///
/// `daysMask` selects the day the window **starts** (Mon=1, Tue=2, … Sun=64).
/// A Monday 22:00→06:00 entry runs Monday 22:00 → Tuesday 06:00.
class ScheduleWindow {
  ScheduleWindow({
    required this.startMinute,
    required this.endMinute,
    required this.daysMask,
  }) {
    if (startMinute < 0 ||
        startMinute >= _minutesPerDay ||
        endMinute < 0 ||
        endMinute >= _minutesPerDay) {
      throw ArgumentError('minutes must be in [0, 1440)');
    }
    if (startMinute == endMinute) {
      throw ArgumentError('zero-length window (start == end) is not allowed');
    }
    if (daysMask <= 0 || daysMask > _allDays) {
      throw ArgumentError('daysMask must be in [1, 127]');
    }
  }

  /// Convenience: build from wall-clock hours/minutes.
  factory ScheduleWindow.fromClock({
    required int startHour,
    required int startMin,
    required int endHour,
    required int endMin,
    required int daysMask,
  }) => ScheduleWindow(
    startMinute: startHour * 60 + startMin,
    endMinute: endHour * 60 + endMin,
    daysMask: daysMask,
  );

  final int startMinute;
  final int endMinute;
  final int daysMask;

  static const int _minutesPerDay = 24 * 60;
  static const int _allDays = 127; // 1|2|4|8|16|32|64

  bool get wrapsMidnight => startMinute > endMinute;

  /// Bit for a [DateTime.weekday] (Mon=1 … Sun=7) → Mon=1, Tue=2, … Sun=64.
  static int bitForWeekday(int weekday) => 1 << (weekday - 1);

  /// Is [dt] (interpreted as local wall-clock) inside this window?
  bool contains(DateTime dt) {
    final minute = dt.hour * 60 + dt.minute;
    final todayBit = bitForWeekday(dt.weekday);
    final yesterdayBit = bitForWeekday(dt.weekday == 1 ? 7 : dt.weekday - 1);

    if (!wrapsMidnight) {
      // Same-day [start, end): only the start day matters.
      return (daysMask & todayBit) != 0 &&
          minute >= startMinute &&
          minute < endMinute;
    }

    // Wrapping: the evening portion belongs to today's mask entry;
    // the after-midnight portion belongs to yesterday's mask entry.
    final inEvening = (daysMask & todayBit) != 0 && minute >= startMinute;
    final inMorning = (daysMask & yesterdayBit) != 0 && minute < endMinute;
    return inEvening || inMorning;
  }

  /// Minutes until this window next opens, from [from]. `null` if it is
  /// currently open. Scans up to 8 days ahead.
  int? minutesUntilNextOpen(DateTime from) {
    if (contains(from)) return null;
    var cursor = DateTime(
      from.year,
      from.month,
      from.day,
      from.hour,
      from.minute,
    );
    for (var i = 0; i < _minutesPerDay * 8; i++) {
      cursor = cursor.add(const Duration(minutes: 1));
      if (contains(cursor)) return i + 1;
    }
    return null;
  }
}
