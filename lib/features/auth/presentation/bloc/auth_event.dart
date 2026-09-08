part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Cold start — try to restore a session from the stored refresh token.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class OtpRequested extends AuthEvent {
  const OtpRequested(this.phone);
  final String phone; // raw input; validated/normalised in the bloc
  @override
  List<Object?> get props => [phone];
}

class OtpResendRequested extends AuthEvent {
  const OtpResendRequested();
}

class OtpSubmitted extends AuthEvent {
  const OtpSubmitted(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}

/// Back out of the OTP screen to the phone entry screen.
class OtpRestarted extends AuthEvent {
  const OtpRestarted();
}

class AuthProfileReloaded extends AuthEvent {
  const AuthProfileReloaded();
}

class LoggedOut extends AuthEvent {
  const LoggedOut({this.everywhere = false});
  final bool everywhere;
  @override
  List<Object?> get props => [everywhere];
}

/// Emitted internally when a refresh fails unrecoverably (interceptor → bloc).
class AuthSessionLost extends AuthEvent {
  const AuthSessionLost();
}
