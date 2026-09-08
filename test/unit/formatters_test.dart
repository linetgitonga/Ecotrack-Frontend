import 'package:ecotrack/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('watts scales to kW', () {
    expect(Formatters.watts(850), '850 W');
    expect(Formatters.watts(1800), '1.8 kW');
    expect(Formatters.watts(12000), '12 kW');
  });

  test('energy Wh scales to kWh', () {
    expect(Formatters.energyWh(640), '640 Wh');
    expect(Formatters.energyWh(3240), '3.24 kWh');
  });

  test('percent', () {
    expect(Formatters.percent(0.8), '80%');
    expect(Formatters.percent(0.1234, decimals: 1), '12.3%');
  });

  group('relative time', () {
    final now = DateTime(2026, 9, 8, 12, 0);
    test('just now', () {
      expect(
        Formatters.relative(
          now.subtract(const Duration(seconds: 10)),
          now: now,
        ),
        'just now',
      );
    });
    test('minutes', () {
      expect(
        Formatters.relative(
          now.subtract(const Duration(minutes: 12)),
          now: now,
        ),
        '12m ago',
      );
    });
    test('hours', () {
      expect(
        Formatters.relative(now.subtract(const Duration(hours: 3)), now: now),
        '3h ago',
      );
    });
    test('lastUpdated wording', () {
      expect(
        Formatters.lastUpdated(
          now.subtract(const Duration(minutes: 5)),
          now: now,
        ),
        'updated 5m ago',
      );
    });
  });
}
