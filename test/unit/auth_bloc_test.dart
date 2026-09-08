import 'package:bloc_test/bloc_test.dart';
import 'package:ecotrack/core/auth/session_manager.dart';
import 'package:ecotrack/core/error/failure.dart';
import 'package:ecotrack/core/error/result.dart';
import 'package:ecotrack/data/repositories/auth_repository.dart';
import 'package:ecotrack/domain/entities/user.dart';
import 'package:ecotrack/domain/value_objects/phone_number.dart';
import 'package:ecotrack/domain/value_objects/role.dart';
import 'package:ecotrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements AuthRepository {}

class _MockSession extends Mock implements SessionManager {}

final _user = User(
  id: 'u1',
  tenantId: 't1',
  phone: PhoneNumber.tryParse('+254712345678')!,
  role: Role.owner,
  displayName: 'Jane W.',
);

const _challenge = OtpChallenge(
  pendingToken: 'pt-1',
  maskedTarget: '+2547•••678',
  expiresIn: Duration(seconds: 300),
);

void main() {
  late _MockRepo repo;
  late _MockSession session;

  setUpAll(() {
    registerFallbackValue(PhoneNumber.tryParse('+254700000000')!);
  });

  setUp(() {
    repo = _MockRepo();
    session = _MockSession();
    when(() => session.attach(onSessionLost: any(named: 'onSessionLost')))
        .thenReturn(null);
    when(session.scheduleProactiveRefresh).thenReturn(null);
    when(session.cancel).thenReturn(null);
  });

  AuthBloc build() => AuthBloc(repo, session);

  blocTest<AuthBloc, AuthState>(
    'AuthStarted with no stored session → Unauthenticated',
    setUp: () => when(repo.restoreSession).thenAnswer(
      (_) async => const Err(UnauthorizedFailure(message: 'none')),
    ),
    build: build,
    act: (b) => b.add(const AuthStarted()),
    expect: () => [isA<AuthRestoring>(), isA<Unauthenticated>()],
  );

  blocTest<AuthBloc, AuthState>(
    'AuthStarted with a valid stored session → Authenticated',
    setUp: () =>
        when(repo.restoreSession).thenAnswer((_) async => Ok(_user)),
    build: build,
    act: (b) => b.add(const AuthStarted()),
    expect: () => [isA<AuthRestoring>(), isA<Authenticated>()],
    verify: (_) => verify(session.scheduleProactiveRefresh).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'happy path: request OTP → verify → Authenticated',
    setUp: () {
      when(() => repo.requestOtp(any(), deviceName: any(named: 'deviceName')))
          .thenAnswer((_) async => const Ok(_challenge));
      when(() => repo.verifyOtp(
            pendingToken: any(named: 'pendingToken'),
            code: any(named: 'code'),
            deviceName: any(named: 'deviceName'),
          )).thenAnswer((_) async => Ok(_user));
    },
    build: build,
    act: (b) async {
      b.add(const OtpRequested('0712345678'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      b.add(const OtpSubmitted('123456'));
    },
    expect: () => [
      isA<OtpRequesting>(),
      isA<OtpPending>(),
      isA<OtpVerifying>(),
      isA<Authenticated>(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'invalid phone → AuthFailure then Unauthenticated, no network call',
    build: build,
    act: (b) => b.add(const OtpRequested('abc')),
    expect: () => [isA<AuthFailure>(), isA<Unauthenticated>()],
    verify: (_) => verifyNever(
      () => repo.requestOtp(any(), deviceName: any(named: 'deviceName')),
    ),
  );

  blocTest<AuthBloc, AuthState>(
    'wrong OTP → AuthFailure then back to OtpPending',
    setUp: () {
      when(() => repo.requestOtp(any(), deviceName: any(named: 'deviceName')))
          .thenAnswer((_) async => const Ok(_challenge));
      when(() => repo.verifyOtp(
            pendingToken: any(named: 'pendingToken'),
            code: any(named: 'code'),
            deviceName: any(named: 'deviceName'),
          )).thenAnswer(
        (_) async => const Err(UnauthorizedFailure(message: 'bad code')),
      );
    },
    build: build,
    act: (b) async {
      b.add(const OtpRequested('0712345678'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      b.add(const OtpSubmitted('000000'));
    },
    expect: () => [
      isA<OtpRequesting>(),
      isA<OtpPending>(),
      isA<OtpVerifying>(),
      isA<AuthFailure>(),
      isA<OtpPending>(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'LoggedOut → Unauthenticated',
    setUp: () => when(repo.logout).thenAnswer((_) async {}),
    build: build,
    seed: () => Authenticated(_user),
    act: (b) => b.add(const LoggedOut()),
    expect: () => [isA<Unauthenticated>()],
    verify: (_) => verify(repo.logout).called(1),
  );
}
