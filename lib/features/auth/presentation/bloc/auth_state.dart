part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Before `AuthStarted` runs — router shows a splash.
class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthRestoring extends AuthState {
  const AuthRestoring();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class OtpRequesting extends AuthState {
  const OtpRequesting();
}

class OtpPending extends AuthState {
  const OtpPending({
    required this.challenge,
    required this.phone,
    this.resendNonce = 0,
  });

  final OtpChallenge challenge;
  final PhoneNumber phone;

  /// Bumped on each successful resend so the screen can restart its countdown.
  final int resendNonce;

  OtpPending copyWith({int? resendNonce}) => OtpPending(
    challenge: challenge,
    phone: phone,
    resendNonce: resendNonce ?? this.resendNonce,
  );

  @override
  List<Object?> get props => [challenge.pendingToken, phone.e164, resendNonce];
}

class OtpVerifying extends AuthState {
  const OtpVerifying();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

/// Transient — a screen shows the message, then a concrete state follows.
class AuthFailure extends AuthState {
  const AuthFailure(this.message, {this.previous});
  final String message;
  final AuthState? previous;
  @override
  List<Object?> get props => [message, previous];
}
