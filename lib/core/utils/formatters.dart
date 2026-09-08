import 'package:intl/intl.dart';

/// Display formatting for energy, power, dates and percentages.
/// Monetary formatting lives on [Money] (`domain/value_objects/money.dart`).
abstract final class Formatters {
  // --- Power / energy --------------------------------------------------
  /// Watts → `"850 W"` or `"1.8 kW"`.
  static String watts(num w) {
    if (w.abs() >= 1000) {
      return '${(w / 1000).toStringAsFixed(w.abs() >= 10000 ? 0 : 1)} kW';
    }
    return '${w.round()} W';
  }

  /// Watt-hours → `"640 Wh"` / `"3.24 kWh"`.
  static String energyWh(num wh) {
    if (wh.abs() >= 1000) return '${(wh / 1000).toStringAsFixed(2)} kWh';
    return '${wh.round()} Wh';
  }

  /// Kilowatt-hours → `"3.24 kWh"`.
  static String kwh(num value) => '${value.toStringAsFixed(2)} kWh';

  static String volts(num v) => '${v.toStringAsFixed(0)} V';
  static String amps(num a) => '${a.toStringAsFixed(2)} A';

  // --- Percent --------------------------------------------------------
  /// `0.8` → `"80%"`. Pass [ratio] in 0..1.
  static String percent(double ratio, {int decimals = 0}) =>
      '${(ratio * 100).toStringAsFixed(decimals)}%';

  // --- Dates / time -------------------------------------------------
  // NOTE: DateTimes are treated as device-local. Site wall-clock
  // (Africa/Nairobi) formatting arrives with the `timezone` package in a later
  // phase; for a KE-only launch device-local == site-local in practice.
  static final DateFormat _dayMonth = DateFormat('d MMM');
  static final DateFormat _dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _weekdayTime = DateFormat('EEE HH:mm');

  static String date(DateTime dt) => _dayMonth.format(dt);
  static String dateFull(DateTime dt) => _dayMonthYear.format(dt);
  static String time(DateTime dt) => _time.format(dt);
  static String weekdayTime(DateTime dt) => _weekdayTime.format(dt);

  /// `"just now"` / `"5m ago"` / `"3h ago"` / `"2d ago"` / a date beyond a week.
  static String relative(DateTime dt, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final d = ref.difference(dt);
    if (d.inSeconds < 45) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return _dayMonth.format(dt);
  }

  /// `"updated 12m ago"` for the connection banner / stale caches.
  static String lastUpdated(DateTime dt, {DateTime? now}) =>
      'updated ${relative(dt, now: now)}';
}
