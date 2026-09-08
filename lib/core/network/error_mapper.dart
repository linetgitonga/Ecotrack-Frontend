import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../error/exceptions.dart';
import '../error/failure.dart';

/// Turns a [DioException] into a typed [Failure] using the backend's actual
/// error shape (`{"error": {"code": "...", "message": "..."}}`, per
/// `backend_design.md`) with an RFC 7807 `problem+json` fallback for Tier B.
abstract final class ErrorMapper {
  static Failure fromDio(DioException e) {
    if (e.error is CertificatePinException) {
      return CertificatePinFailure(cause: e.error);
    }

    final type = e.type;
    if (type == DioExceptionType.connectionError) {
      return NetworkFailure(cause: e);
    }
    if (type == DioExceptionType.cancel) {
      return const NetworkFailure(message: 'Request cancelled');
    }
    if (type == DioExceptionType.badCertificate) {
      return CertificatePinFailure(cause: e);
    }
    if (type.name.toLowerCase().contains('timeout')) {
      return TimeoutFailure(cause: e);
    }

    final response = e.response;
    if (response == null) return UnknownFailure(cause: e);
    return fromResponse(
      statusCode: response.statusCode ?? 0,
      body: response.data,
      retryAfterHeader: response.headers.value(ApiHeaders.retryAfter),
      cause: e,
    );
  }

  static Failure fromApiException(ApiException e) => fromResponse(
    statusCode: e.statusCode ?? 0,
    body: e.raw,
    retryAfterHeader: e.retryAfter?.inSeconds.toString(),
    cause: e,
  );

  static Failure fromResponse({
    required int statusCode,
    Object? body,
    String? retryAfterHeader,
    Object? cause,
  }) {
    final parsed = _parseBody(body);
    final code = parsed.code;
    final message = parsed.message;
    final fieldErrors = parsed.fieldErrors;

    if (code == 'STEP_UP_REQUIRED' || code == 'STEP_UP_MFA_REQUIRED') {
      return StepUpRequiredFailure(cause: cause);
    }

    switch (statusCode) {
      case 400 || 422:
        return ValidationFailure(
          message: message ?? 'Please check the highlighted fields',
          fieldErrors: fieldErrors,
          code: code,
          cause: cause,
        );
      case 401:
        return UnauthorizedFailure(
          message: message ?? 'Session expired',
          code: code,
          cause: cause,
        );
      case 403:
        return ForbiddenFailure(
          message: message ?? 'Not permitted',
          code: code,
          cause: cause,
        );
      case 404:
        return NotFoundFailure(
          message: message ?? 'Not found',
          code: code,
          cause: cause,
        );
      case 409:
        return ConflictFailure(
          message: message ?? 'That conflicts with the current state',
          code: code,
          cause: cause,
        );
      case 429:
        return RateLimitedFailure(
          message: message ?? 'Too many requests',
          retryAfter: _parseRetryAfter(retryAfterHeader),
          code: code,
          cause: cause,
        );
      case >= 500:
        return ServerFailure(
          message: message ?? 'Something went wrong',
          code: code,
          cause: cause,
        );
      default:
        return ServerFailure(
          message: message ?? 'Unexpected response ($statusCode)',
          code: code,
          cause: cause,
        );
    }
  }

  static Duration? _parseRetryAfter(String? header) {
    if (header == null) return null;
    final seconds = int.tryParse(header.trim());
    return seconds == null ? null : Duration(seconds: seconds);
  }

  static ({String? code, String? message, Map<String, String> fieldErrors})
  _parseBody(Object? body) {
    if (body is! Map) {
      return (code: null, message: null, fieldErrors: const {});
    }

    // Backend shape: {"error": {"code": "...", "message": "..."}}
    final err = body['error'];
    if (err is Map) {
      return (
        code: err['code']?.toString(),
        message: err['message']?.toString(),
        fieldErrors: _fields(err['fields'] ?? err['field_errors']),
      );
    }

    // RFC 7807 problem+json fallback (Tier B): {"title","detail","errors":{...}}
    final detail = body['detail'] ?? body['title'] ?? body['message'];
    return (
      code: body['type']?.toString() ?? body['code']?.toString(),
      message: detail?.toString(),
      fieldErrors: _fields(body['errors'] ?? body['field_errors']),
    );
  }

  static Map<String, String> _fields(Object? raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) {
      final msg = v is List && v.isNotEmpty ? v.first : v;
      return MapEntry(k.toString(), msg.toString());
    });
  }
}
