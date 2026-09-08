import 'package:equatable/equatable.dart';

/// Domain-level error. Every repository / use case surfaces one of these instead
/// of throwing. UI maps it to copy via `error_messages.dart` + the §8 matrix.
sealed class Failure extends Equatable {
  const Failure({required this.message, this.code, this.cause});

  /// Developer-facing summary (already logged; not shown verbatim to users).
  final String message;

  /// Backend `error.code` when present (e.g. `STEP_UP_REQUIRED`, `INVALID_TOKEN`).
  final String? code;

  /// Original exception / object, for logging only.
  final Object? cause;

  @override
  List<Object?> get props => [runtimeType, message, code];

  @override
  bool get stringify => true;
}

/// No network transport at all (device offline, DNS failure, connection refused).
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network unavailable', super.cause});
}

/// The request was sent but timed out.
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'The request timed out', super.cause});
}

/// The app is in offline mode; the action was queued or cache was served.
class OfflineFailure extends Failure {
  const OfflineFailure({super.message = 'You are offline', super.cause});
}

/// 401 — token missing / expired / revoked after a refresh attempt.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expired',
    super.code,
    super.cause,
  });
}

/// 403 without a step-up requirement — the role can't do this.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'Not permitted',
    super.code,
    super.cause,
  });
}

/// 403 `STEP_UP_REQUIRED` — re-verify by OTP, then retry.
class StepUpRequiredFailure extends Failure {
  const StepUpRequiredFailure({
    super.message = 'Verification required',
    super.cause,
  }) : super(code: 'STEP_UP_REQUIRED');
}

/// 404.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Not found', super.code, super.cause});
}

/// 409 — e.g. shedding a `is_critical` appliance, or a binding already exists.
class ConflictFailure extends Failure {
  const ConflictFailure({required super.message, super.code, super.cause});
}

/// 429 — includes the retry-after hint when the server sends one.
class RateLimitedFailure extends Failure {
  const RateLimitedFailure({
    super.message = 'Too many requests',
    this.retryAfter,
    super.code,
    super.cause,
  });

  final Duration? retryAfter;

  @override
  List<Object?> get props => [...super.props, retryAfter];
}

/// 400 — field-level validation errors keyed by field name.
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Please check the highlighted fields',
    this.fieldErrors = const {},
    super.code,
    super.cause,
  });

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// 5xx or an unparseable response.
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Something went wrong',
    super.code,
    super.cause,
  });
}

/// Local cache/database error, or a requested row genuinely isn't cached offline.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'No saved data available', super.cause});
}

/// LAN certificate fingerprint did not match the pinned value.
class CertificatePinFailure extends Failure {
  const CertificatePinFailure({
    super.message = 'Could not verify the hub securely',
    super.cause,
  });
}

/// Anything not otherwise classified.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Unexpected error', super.cause});
}
