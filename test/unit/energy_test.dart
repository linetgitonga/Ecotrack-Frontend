import 'package:ecotrack/core/utils/energy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('energy = max - min over the window', () {
    expect(EnergyCalc.wattHours([100, 250, 175, 400]), 300);
  });

  test('counter reset is absorbed by max(_, 0) — order independent', () {
    // device replaced mid-window: 900,950, then new device 10,60
    expect(EnergyCalc.wattHours([900, 950, 10, 60]), 940); // 950 - 10
  });

  test('dropped samples cost resolution, not the total', () {
    expect(EnergyCalc.wattHours([0, 500]), 500);
    expect(EnergyCalc.wattHours([0, 100, 200, 300, 400, 500]), 500);
  });

  test('clock_conf < 2 rows are excluded', () {
    final r = EnergyCalc.wattHoursFromCumulative([
      (cumulativeWh: 100, clockConf: 2),
      (cumulativeWh: 5000, clockConf: 1), // drifted — ignored
      (cumulativeWh: 400, clockConf: 2),
    ]);
    expect(r, 300);
  });

  test('empty / all-untrusted → 0', () {
    expect(EnergyCalc.wattHours(const []), 0);
    expect(
      EnergyCalc.wattHoursFromCumulative([(cumulativeWh: 10, clockConf: 0)]),
      0,
    );
  });
}
