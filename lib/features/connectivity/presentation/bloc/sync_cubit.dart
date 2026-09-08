import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/sync/sync_engine.dart';
import '../../../../data/local/database/daos/sync_dao.dart';

class SyncViewState extends Equatable {
  const SyncViewState({this.pending = 0, this.status = SyncStatus.idle});
  final int pending;
  final SyncStatus status;

  bool get hasQueue => pending > 0;

  @override
  List<Object?> get props => [pending, status];
}

/// Global — surfaces the outbox depth + sync activity for the shell banner.
@lazySingleton
class SyncCubit extends Cubit<SyncViewState> {
  SyncCubit(this._dao, this._engine) : super(const SyncViewState()) {
    _pendingSub = _dao.watchPendingCount().listen(
          (n) => emit(SyncViewState(pending: n, status: state.status)),
        );
    _statusSub = _engine.status.listen(
      (s) => emit(SyncViewState(pending: state.pending, status: s)),
    );
  }

  final SyncDao _dao;
  final SyncEngine _engine;
  late final StreamSubscription<int> _pendingSub;
  late final StreamSubscription<SyncStatus> _statusSub;

  void syncNow() => _engine.syncNow();

  @override
  Future<void> close() async {
    await _pendingSub.cancel();
    await _statusSub.cancel();
    return super.close();
  }
}
