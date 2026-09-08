import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// A KES monetary amount held at **scale 6** (millionths), matching
/// `Database_Design §0`: store at working precision, round only at display.
///
/// Never sum rounded values — sum [Money] then call [formatted] once.
class Money extends Equatable implements Comparable<Money> {
  const Money._(this.micros, {this.isEstimated = false, this.currency = 'KES'});

  /// Raw amount in millionths of a shilling (KES 1.00 == 1_000_000).
  final int micros;

  /// Propagated from `cost_hourly.is_estimated` etc. — the UI must label it.
  final bool isEstimated;

  final String currency;

  static const int _scale = 1000000;

  static const Money zero = Money._(0);

  factory Money.fromMicros(int micros, {bool isEstimated = false}) =>
      Money._(micros, isEstimated: isEstimated);

  /// From a decimal string as the API sends it (e.g. `"1234.560000"`).
  factory Money.parse(String value, {bool isEstimated = false}) {
    final d = Decimalish.parse(value);
    return Money._(d, isEstimated: isEstimated);
  }

  factory Money.fromDouble(num value, {bool isEstimated = false}) =>
      Money._((value * _scale).round(), isEstimated: isEstimated);

  double get asDouble => micros / _scale;

  Money operator +(Money other) => Money._(
    micros + other.micros,
    isEstimated: isEstimated || other.isEstimated,
    currency: currency,
  );

  Money operator -(Money other) => Money._(
    micros - other.micros,
    isEstimated: isEstimated || other.isEstimated,
    currency: currency,
  );

  Money operator *(num factor) => Money._(
    (micros * factor).round(),
    isEstimated: isEstimated,
    currency: currency,
  );

  bool get isNegative => micros < 0;
  bool get isZero => micros == 0;

  Money copyWith({bool? isEstimated}) => Money._(
    micros,
    isEstimated: isEstimated ?? this.isEstimated,
    currency: currency,
  );

  static final NumberFormat _fmt = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'KES ',
    decimalDigits: 2,
  );

  /// Display string rounded to 2 dp, e.g. `KES 1,234.56`.
  String get formatted => _fmt.format(asDouble);

  /// [formatted] with a `≈` prefix when [isEstimated].
  String get formattedWithEstimate => isEstimated ? '≈ $formatted' : formatted;

  @override
  int compareTo(Money other) => micros.compareTo(other.micros);

  @override
  List<Object?> get props => [micros, currency];

  @override
  String toString() => 'Money($formatted${isEstimated ? ', est' : ''})';
}

/// Minimal fixed-point parse: `"1234.560000"` → micros, no float round-trip.
abstract final class Decimalish {
  static int parse(String value) {
    final trimmed = value.trim();
    final neg = trimmed.startsWith('-');
    final body = neg ? trimmed.substring(1) : trimmed;
    final parts = body.split('.');
    final whole = int.parse(parts[0].isEmpty ? '0' : parts[0]);
    var fracStr = parts.length > 1 ? parts[1] : '';
    if (fracStr.length > 6) {
      fracStr = fracStr.substring(0, 6); // truncate beyond scale 6
    } else {
      fracStr = fracStr.padRight(6, '0');
    }
    final frac = int.parse(fracStr.isEmpty ? '0' : fracStr);
    final micros = whole * 1000000 + frac;
    return neg ? -micros : micros;
  }
}
