import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/auth/session_manager.dart';
import '../../../../core/constants/error_messages.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/value_objects/phone_number.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Global auth/session bloc. Provided above `MaterialApp` in `app.dart`; the
/// router redirect and the connectivity indicator both listen to it.
@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo, this._session) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<OtpRequested>(_onOtpRequested, transformer: droppable());
    on<OtpResendRequested>(_onResend, transformer: droppable());
    on<OtpSubmitted>(_onOtpSubmitted, transformer: droppable());
    on<OtpRestarted>((_, emit) => emit(const Unauthenticated()));
    on<AuthProfileReloaded>(_onReload);
    on<LoggedOut>(_onLogout);
    on<AuthSessionLost>(_onSessionLost);

    _session.attach(onSessionLost: () => add(const AuthSessionLost()));
  }

  final AuthRepository _repo;
  final SessionManager _session;

  /// Device label for `device_name` — set by `bootstrap` (device_info).
  String? deviceName;

  User? get user => switch (state) {
    Authenticated(:final user) => user,
    _ => null,
  };

  Future<void> _onStarted(AuthStarted e, Emitter<AuthState> emit) async {
    emit(const AuthRestoring());
    final r = await _repo.restoreSession();
    r.when(
      ok: (user) {
        _session.scheduleProactiveRefresh();
        emit(Authenticated(user));
      },
      err: (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onOtpRequested(OtpRequested e, Emitter<AuthState> emit) async {
    final phone = PhoneNumber.tryParse(e.phone);
    if (phone == null) {
      emit(const AuthFailure('Enter a valid phone number'));
      emit(const Unauthenticated());
      return;
    }
    emit(const OtpRequesting());
    final r = await _repo.requestOtp(phone, deviceName: deviceName);
    r.when(
      ok: (challenge) => emit(OtpPending(challenge: challenge, phone: phone)),
      err: (f) {
        emit(AuthFailure(ErrorMessages.forFailure(f)));
        emit(const Unauthenticated());
      },
    );
  }

  Future<void> _onResend(OtpResendRequested e, Emitter<AuthState> emit) async {
    final s = state;
    if (s is! OtpPending) return;
    final r = await _repo.resendOtp(s.challenge.pendingToken);
    r.when(
      ok: (_) => emit(s.copyWith(resendNonce: s.resendNonce + 1)),
      err: (f) => emit(AuthFailure(ErrorMessages.forFailure(f), previous: s)),
    );
  }

  Future<void> _onOtpSubmitted(OtpSubmitted e, Emitter<AuthState> emit) async {
    final s = state;
    final pending = s is OtpPending
        ? s
        : (s is AuthFailure && s.previous is OtpPending
              ? s.previous! as OtpPending
              : null);
    if (pending == null) return;

    emit(const OtpVerifying());
    final r = await _repo.verifyOtp(
      pendingToken: pending.challenge.pendingToken,
      code: e.code,
      deviceName: deviceName,
    );
    r.when(
      ok: (user) {
        _session.scheduleProactiveRefresh();
        emit(Authenticated(user));
      },
      err: (f) {
        emit(AuthFailure(ErrorMessages.forFailure(f), previous: pending));
        emit(pending);
      },
    );
  }

  Future<void> _onReload(AuthProfileReloaded e, Emitter<AuthState> emit) async {
    if (state is! Authenticated) return;
    final r = await _repo.reloadMe();
    r.when(ok: (u) => emit(Authenticated(u)), err: (_) {});
  }

  Future<void> _onLogout(LoggedOut e, Emitter<AuthState> emit) async {
    _session.cancel();
    if (e.everywhere) {
      await _repo.revokeAllSessions();
    } else {
      await _repo.logout();
    }
    emit(const Unauthenticated());
  }

  void _onSessionLost(AuthSessionLost e, Emitter<AuthState> emit) {
    _session.cancel();
    emit(const Unauthenticated());
  }
}
