import 'package:ecotrack/core/utils/schedule_window.dart';
import 'package:flutter_test/flutter_test.dart';

// days_mask bits: Mon=1, Tue=2, Wed=4, Thu=8, Fri=16, Sat=32, Sun=64
const mon = 1, tue = 2, wed = 4;

// 2026-01-05 is a Monday; the following days line up Mon..Sun.
DateTime monday(int h, int m) => DateTime(2026, 1, 5, h, m);
DateTime tuesday(int h, int m) => DateTime(2026, 1, 6, h, m);
DateTime wednesday(int h, int m) => DateTime(2026, 1, 7, h, m);
DateTime thursday(int h, int m) => DateTime(2026, 1, 8, h, m);
DateTime friday(int h, int m) => DateTime(2026, 1, 9, h, m);

void main() {
  test('anchor date sanity', () {
    expect(monday(0, 0).weekday, DateTime.monday);
  });

  group('same-day window [start, end)', () {
    final w = ScheduleWindow.fromClock(
      startHour: 18,
      startMin: 0,
      endHour: 22,
      endMin: 0,
      daysMask: mon,
    );

    test(
      'inside on the selected day',
      () => expect(w.contains(monday(20, 0)), isTrue),
    );
    test('end is exclusive', () => expect(w.contains(monday(22, 0)), isFalse));
    test('start is inclusive', () => expect(w.contains(monday(18, 0)), isTrue));
    test('wrong day', () => expect(w.contains(tuesday(20, 0)), isFalse));
  });

  group('overnight wrap (Mon 22:00 -> 06:00)', () {
    final w = ScheduleWindow.fromClock(
      startHour: 22,
      startMin: 0,
      endHour: 6,
      endMin: 0,
      daysMask: mon,
    );

    test('wrapsMidnight is set', () => expect(w.wrapsMidnight, isTrue));
    test(
      'Mon 22:00 inside (start inclusive)',
      () => expect(w.contains(monday(22, 0)), isTrue),
    );
    test('Mon 23:30 inside', () => expect(w.contains(monday(23, 30)), isTrue));
    test(
      'Tue 05:59 inside (morning belongs to Monday entry)',
      () => expect(w.contains(tuesday(5, 59)), isTrue),
    );
    test(
      'Tue 06:00 outside (end exclusive)',
      () => expect(w.contains(tuesday(6, 0)), isFalse),
    );
    test(
      'Mon 21:59 outside',
      () => expect(w.contains(monday(21, 59)), isFalse),
    );
    test(
      'Tue 22:00 outside (mask selects Monday start only)',
      () => expect(w.contains(tuesday(22, 0)), isFalse),
    );
    test(
      'Wed 05:00 outside',
      () => expect(w.contains(wednesday(5, 0)), isFalse),
    );
  });

  group('multi-day mask with wrap (Mon|Tue|Wed 23:00 -> 05:00)', () {
    final w = ScheduleWindow.fromClock(
      startHour: 23,
      startMin: 0,
      endHour: 5,
      endMin: 0,
      daysMask: mon | tue | wed,
    );
    test(
      'Tue 02:00 inside (Monday-started)',
      () => expect(w.contains(tuesday(2, 0)), isTrue),
    );
    test(
      'Thu 02:00 inside (Wednesday-started)',
      () => expect(w.contains(thursday(2, 0)), isTrue),
    );
    test('Fri 02:00 outside', () => expect(w.contains(friday(2, 0)), isFalse));
  });

  test('zero-length window rejected', () {
    expect(
      () => ScheduleWindow.fromClock(
        startHour: 8,
        startMin: 0,
        endHour: 8,
        endMin: 0,
        daysMask: mon,
      ),
      throwsArgumentError,
    );
  });

  test('out-of-range minutes rejected', () {
    expect(
      () => ScheduleWindow(startMinute: -1, endMinute: 100, daysMask: mon),
      throwsArgumentError,
    );
  });

  test('minutesUntilNextOpen', () {
    final w = ScheduleWindow.fromClock(
      startHour: 22,
      startMin: 0,
      endHour: 6,
      endMin: 0,
      daysMask: mon,
    );
    expect(w.minutesUntilNextOpen(monday(21, 0)), 60);
    expect(w.minutesUntilNextOpen(monday(23, 0)), isNull);
  });
}
