import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/auth/step_up_controller.dart';
import '../../../../core/constants/error_messages.dart';
import '../../../../core/error/result.dart';
import '../../../../data/repositories/site_repository.dart';
import '../../../../domain/entities/site.dart';

class MembersState extends Equatable {
  const MembersState({
    this.loading = true,
    this.members = const [],
    this.error,
    this.busyUserId,
  });

  final bool loading;
  final List<SiteMember> members;
  final String? error;

  /// User id of a row with an in-flight role change / removal.
  final String? busyUserId;

  MembersState copyWith({
    bool? loading,
    List<SiteMember>? members,
    Object? error = _s,
    Object? busyUserId = _s,
  }) => MembersState(
    loading: loading ?? this.loading,
    members: members ?? this.members,
    error: identical(error, _s) ? this.error : error as String?,
    busyUserId: identical(busyUserId, _s)
        ? this.busyUserId
        : busyUserId as String?,
  );

  static const _s = Object();

  @override
  List<Object?> get props => [loading, members, error, busyUserId];
}

/// Per-site member management. Removal needs step-up: the UI calls
/// [beginRemove] → shows the OTP modal → [confirmRemove].
@injectable
class MembersCubit extends Cubit<MembersState> {
  MembersCubit(this._repo, this._stepUp) : super(const MembersState());

  final SiteRepository _repo;
  final StepUpController _stepUp;
  StreamSubscription<Result<List<SiteMember>>>? _sub;
  String? _siteId;

  void subscribe(String siteId) {
    _siteId = siteId;
    _sub?.cancel();
    _sub = _repo.watchMembers(siteId).listen((r) {
      r.when(
        ok: (members) =>
            emit(state.copyWith(loading: false, members: members, error: null)),
        err: (f) => emit(
          state.copyWith(loading: false, error: ErrorMessages.forFailure(f)),
        ),
      );
    });
  }

  Future<Result<Unit>> invite({
    required String phoneE164,
    required String role,
  }) => _repo.inviteMember(_siteId!, phoneE164: phoneE164, role: role);

  Future<void> changeRole(String userId, String role) async {
    emit(state.copyWith(busyUserId: userId));
    final r = await _repo.changeMemberRole(_siteId!, userId, role);
    emit(
      state.copyWith(
        busyUserId: null,
        error: r.isErr ? ErrorMessages.forFailure(r.failureOrNull!) : null,
      ),
    );
  }

  /// Step-up step 1.
  Future<Result<Unit>> beginRemove() => _stepUp.initiate();

  /// Step-up step 2 + the actual removal.
  Future<Result<Unit>> confirmRemove(String userId, String code) async {
    final verified = await _stepUp.verify(code);
    if (verified.isErr) return verified;
    emit(state.copyWith(busyUserId: userId));
    final r = await _repo.removeMember(_siteId!, userId);
    emit(state.copyWith(busyUserId: null));
    return r;
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
