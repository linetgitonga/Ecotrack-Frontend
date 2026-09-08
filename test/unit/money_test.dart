import 'package:ecotrack/domain/value_objects/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a scale-6 decimal string without float error', () {
    final m = Money.parse('1234.560000');
    expect(m.micros, 1234560000);
    expect(m.formatted, 'KES 1,234.56');
  });

  test('truncates fraction beyond scale 6', () {
    expect(Money.parse('0.1234567').micros, 123456);
  });

  test('a 5W standby hour keeps precision that 2dp storage would lose', () {
    // ~KES 0.125 — rounds to 0.13 at 2dp (a 4% error). Scale 6 keeps it.
    final perHour = Money.fromMicros(125000);
    var total = Money.zero;
    for (var i = 0; i < 720; i++) {
      total += perHour;
    }
    expect(total.micros, 90000000); // exactly KES 90.00 over the month
    expect(total.formatted, 'KES 90.00');
  });

  test(
    'estimated flag propagates through addition and prefixes the display',
    () {
      final a = Money.fromMicros(1000000);
      final b = Money.fromMicros(500000, isEstimated: true);
      final sum = a + b;
      expect(sum.isEstimated, isTrue);
      expect(sum.formattedWithEstimate, '≈ KES 1.50');
    },
  );

  test('negative amounts', () {
    final m = Money.parse('-12.5');
    expect(m.isNegative, isTrue);
    expect(m.micros, -12500000);
  });

  test('equality by micros + currency', () {
    expect(Money.fromMicros(100), Money.fromMicros(100));
    expect(Money.fromDouble(1.0), Money.fromMicros(1000000));
  });
}
