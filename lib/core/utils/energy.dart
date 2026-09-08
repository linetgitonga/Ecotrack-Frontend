/// Energy derived from cumulative counters, per Database_Design §1.4 / §0:
///
///   energy = max(0, max(cumulative) − min(cumulative))
///
/// Dropped samples cost resolution, not totals. `max(_, 0)` absorbs counter
/// resets and device replacement. Samples with `clock_conf < 2` are excluded
/// (RTC-drifted data must not land in the wrong tariff hour).
abstract final class EnergyCalc {
  static const int _clockConfNtpSynced = 2;

  /// [readings] as `(cumulativeWh, clockConf)` pairs, any order.
  static double wattHoursFromCumulative(
    Iterable<({double cumulativeWh, int clockConf})> readings,
  ) {
    double? min;
    double? max;
    for (final r in readings) {
      if (r.clockConf < _clockConfNtpSynced) continue;
      min = (min == null || r.cumulativeWh < min) ? r.cumulativeWh : min;
      max = (max == null || r.cumulativeWh > max) ? r.cumulativeWh : max;
    }
    if (min == null || max == null) return 0;
    final delta = max - min;
    return delta > 0 ? delta : 0;
  }

  /// Convenience for already-trusted, plain values.
  static double wattHours(Iterable<double> cumulativeWh) {
    double? min;
    double? max;
    for (final v in cumulativeWh) {
      min = (min == null || v < min) ? v : min;
      max = (max == null || v > max) ? v : max;
    }
    if (min == null || max == null) return 0;
    final delta = max - min;
    return delta > 0 ? delta : 0;
  }
}
