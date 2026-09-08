import '../constants/app_constants.dart';

/// Pure input validators. Return `null` when valid, else an error string
/// suitable for a `TextFormField.validator`.
abstract final class Validators {
  /// Backend contract: `^\+\d{9,15}$` (E.164). We also accept local Kenyan
  /// forms and normalise via [normalizePhone] before sending.
  static final RegExp _e164 = RegExp(r'^\+\d{9,15}$');

  static String? phone(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return 'Enter your phone number';
    final normalized = normalizePhone(v);
    if (normalized == null || !_e164.hasMatch(normalized)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// `0712345678` / `712345678` / `+254712345678` / `254712345678` → `+254712345678`.
  /// Returns null if it can't be made into a plausible E.164 string.
  static String? normalizePhone(String raw) {
    var v = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (v.isEmpty) return null;
    if (v.startsWith('+')) {
      return _e164.hasMatch(v) ? v : null;
    }
    if (v.startsWith('00')) {
      v = '+${v.substring(2)}';
    } else if (v.startsWith('0')) {
      v = '${AppConstants.phoneCountryCode}${v.substring(1)}';
    } else if (v.startsWith('254')) {
      v = '+$v';
    } else if (v.length <= 10) {
      v = '${AppConstants.phoneCountryCode}$v';
    } else {
      v = '+$v';
    }
    return _e164.hasMatch(v) ? v : null;
  }

  static String? otp(String? raw) {
    final v = (raw ?? '').trim();
    if (v.length != AppConstants.otpLength || !RegExp(r'^\d+$').hasMatch(v)) {
      return 'Enter the ${AppConstants.otpLength}-digit code';
    }
    return null;
  }

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? raw, {bool required = false}) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return required ? 'Enter an email address' : null;
    return _email.hasMatch(v) ? null : 'Enter a valid email address';
  }

  static String? notEmpty(String? raw, {String field = 'This field'}) {
    return (raw ?? '').trim().isEmpty ? '$field is required' : null;
  }

  /// KPLC meter number: 11 digits (STS). Optional.
  static String? kplcMeterNo(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return null;
    return RegExp(r'^\d{11}$').hasMatch(v)
        ? null
        : 'Meter number should be 11 digits';
  }
}
