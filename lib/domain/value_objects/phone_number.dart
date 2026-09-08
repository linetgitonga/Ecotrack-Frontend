import 'package:equatable/equatable.dart';

import '../../core/utils/validators.dart';

/// A validated E.164 phone number (the primary identity in KE).
class PhoneNumber extends Equatable {
  const PhoneNumber._(this.e164);

  /// e.g. `+254712345678`
  final String e164;

  /// Returns null if [raw] can't be normalised to a valid E.164 string.
  static PhoneNumber? tryParse(String raw) {
    final normalized = Validators.normalizePhone(raw);
    return normalized == null ? null : PhoneNumber._(normalized);
  }

  /// `+254 712 •••• 678` style — for display / OTP screens.
  String get masked {
    if (e164.length < 7) return e164;
    final head = e164.substring(0, e164.length - 6);
    final tail = e164.substring(e164.length - 3);
    return '$head•••$tail';
  }

  /// Local display: `0712 345 678` for `+254…`.
  String get national {
    if (e164.startsWith('+254') && e164.length == 13) {
      final n = '0${e164.substring(4)}';
      return '${n.substring(0, 4)} ${n.substring(4, 7)} ${n.substring(7)}';
    }
    return e164;
  }

  @override
  List<Object?> get props => [e164];

  @override
  String toString() => e164;
}
