import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/error_messages.dart';
import '../../../../core/error/result.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/entities/auth_session.dart';

class SessionsState extends Equatable {
  const SessionsState({
    this.loading = true,
    this.sessions = const [],
    this.error,
  });

  final bool loading;
  final List<AuthSession> sessions;
  final String? error;

  SessionsState copyWith({
    bool? loading,
    List<AuthSession>? sessions,
    Object? error = _s,
  }) => SessionsState(
    loading: loading ?? this.loading,
    sessions: sessions ?? this.sessions,
    error: identical(error, _s) ? this.error : error as String?,
  );

  static const _s = Object();

  @override
  List<Object?> get props => [loading, sessions, error];
}

@injectable
class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit(this._repo) : super(const SessionsState());
  final AuthRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    final r = await _repo.sessions();
    r.when(
      ok: (list) => emit(SessionsState(loading: false, sessions: list)),
      err: (f) => emit(
        state.copyWith(loading: false, error: ErrorMessages.forFailure(f)),
      ),
    );
  }

  Future<Result<Unit>> revoke(String id) async {
    final r = await _repo.revokeSession(id);
    if (r.isOk) await load();
    return r;
  }
}
