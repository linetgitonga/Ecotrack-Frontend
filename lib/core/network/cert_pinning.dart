import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;

import '../error/exceptions.dart';

/// SHA-256 (DER) certificate pinning for the LAN transport. The expected
/// fingerprint comes from the cloud during pairing (`GET /hubs/{id}/connection`)
/// and is stored per-hub in secure storage.
///
/// Not used on web (LAN is disabled there — System_Design §13.2).
class CertificatePinner {
  CertificatePinner(this._expectedFingerprint, {required this.host});

  /// Lower-case hex SHA-256 of the DER-encoded leaf certificate.
  final String _expectedFingerprint;
  final String host;

  /// Plug into `HttpClient.badCertificateCallback`. Returns true only when the
  /// presented leaf matches the pin (self-signed is expected, so the default
  /// chain check having failed is fine).
  bool allowBadCertificate(X509Certificate cert, String host, int port) {
    final actual = fingerprintOf(cert);
    return _constantTimeEquals(actual, _expectedFingerprint.toLowerCase());
  }

  /// Throwing variant for explicit checks.
  void verify(X509Certificate cert) {
    final actual = fingerprintOf(cert);
    if (!_constantTimeEquals(actual, _expectedFingerprint.toLowerCase())) {
      throw CertificatePinException(
        host,
        expected: _expectedFingerprint,
        actual: actual,
      );
    }
  }

  static String fingerprintOf(X509Certificate cert) {
    final digest = crypto.sha256.convert(cert.der);
    return digest.toString(); // lower-case hex
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

/// Convenience for tests / logging: pin string from raw DER bytes.
String sha256Hex(List<int> der) => crypto.sha256.convert(der).toString();

/// Base64 form some tooling emits (`sha256/BASE64`).
String sha256Base64(List<int> der) =>
    base64.encode(crypto.sha256.convert(der).bytes);
