/// Low-level exceptions thrown inside the data layer. They never escape a
/// repository — the error interceptor / repository maps them to a [Failure].
library;

/// Raised by the Dio error interceptor with the already-classified HTTP status.
class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.fieldErrors = const {},
    this.retryAfter,
    this.raw,
  });

  final int? statusCode;
  final String message;
  final String? code;
  final Map<String, String> fieldErrors;
  final Duration? retryAfter;
  final Object? raw;

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}

/// LAN transport: presented certificate fingerprint != pinned value.
class CertificatePinException implements Exception {
  CertificatePinException(this.host, {this.expected, this.actual});

  final String host;
  final String? expected;
  final String? actual;

  @override
  String toString() => 'CertificatePinException($host)';
}

/// A read hit the local DB but the row genuinely isn't cached (offline + cold).
class CacheMissException implements Exception {
  CacheMissException(this.key);
  final String key;

  @override
  String toString() => 'CacheMissException($key)';
}
