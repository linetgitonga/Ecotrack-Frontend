import '../error/failure.dart';

/// Maps a [Failure] to user-facing copy. Kept as plain strings for now; moves to
/// ARB / `AppLocalizations` when localization lands (Phase 10). The §8 error
/// matrix in the plan drives these.
abstract final class ErrorMessages {
  static String forFailure(Failure f) => switch (f) {
    NetworkFailure() =>
      'No internet connection. Showing saved data where available.',
    TimeoutFailure() => 'That took too long. Please try again.',
    OfflineFailure() =>
      "You're offline. Your changes are queued and will sync automatically.",
    UnauthorizedFailure() => 'Your session has expired. Please sign in again.',
    ForbiddenFailure() => "You don't have permission to do that.",
    StepUpRequiredFailure() =>
      'For your security, please verify with a one-time code to continue.',
    NotFoundFailure() => "We couldn't find that. It may have been removed.",
    ConflictFailure(:final message) => message,
    RateLimitedFailure(:final retryAfter) =>
      retryAfter == null
          ? 'Too many attempts. Please wait a moment and try again.'
          : 'Too many attempts. Try again in ${retryAfter.inSeconds}s.',
    ValidationFailure(:final fieldErrors) =>
      fieldErrors.isEmpty
          ? 'Please check your input and try again.'
          : fieldErrors.values.first,
    ServerFailure() => 'Something went wrong on our side. Please try again.',
    CacheFailure() => 'No saved data available yet. Connect to load it.',
    CertificatePinFailure() =>
      "We couldn't securely verify your hub. Switched to remote access.",
    UnknownFailure() => 'Something unexpected happened. Please try again.',
  };
}
