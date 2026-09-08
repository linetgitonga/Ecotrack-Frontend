import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/error_messages.dart';
import '../../../../data/remote/api/tierb_api.dart';
import '../../../../domain/entities/device.dart';

class AutomationState extends Equatable {
  const AutomationState({
    this.loading = true,
    this.modes = const [],
    this.schedules = const [],
    this.rules = const [],
    this.budgets = const [],
    this.error,
  });

  final bool loading;
  final List<EnergyMode> modes;
  final List<AutomationItem> schedules;
  final List<AutomationItem> rules;
  final List<BudgetItem> budgets;
  final String? error;

  AutomationState copyWith({
    bool? loading,
    List<EnergyMode>? modes,
    List<AutomationItem>? schedules,
    List<AutomationItem>? rules,
    List<BudgetItem>? budgets,
    Object? error = _s,
  }) =>
      AutomationState(
        loading: loading ?? this.loading,
        modes: modes ?? this.modes,
        schedules: schedules ?? this.schedules,
        rules: rules ?? this.rules,
        budgets: budgets ?? this.budgets,
        error: identical(error, _s) ? this.error : error as String?,
      );

  static const _s = Object();

  @override
  List<Object?> get props => [loading, modes, schedules, rules, budgets, error];
}

@injectable
class AutomationCubit extends Cubit<AutomationState> {
  AutomationCubit(this._api) : super(const AutomationState());
  final TierBApi _api;
  String _siteId = '';

  Future<void> load(String siteId) async {
    _siteId = siteId;
    emit(state.copyWith(loading: true, error: null));
    final r = await Future.wait([
      _api.modes(_siteId),
      _api.schedules(_siteId),
      _api.rules(_siteId),
      _api.budgets(_siteId),
    ]);
    emit(AutomationState(
      loading: false,
      modes: (r[0] as dynamic).valueOrNull as List<EnergyMode>? ?? const [],
      schedules:
          (r[1] as dynamic).valueOrNull as List<AutomationItem>? ?? const [],
      rules: (r[2] as dynamic).valueOrNull as List<AutomationItem>? ?? const [],
      budgets: (r[3] as dynamic).valueOrNull as List<BudgetItem>? ?? const [],
      error: (r[0] as dynamic).isErr
          ? ErrorMessages.forFailure((r[0] as dynamic).failureOrNull)
          : null,
    ));
  }

  Future<void> activateMode(String modeId) async {
    emit(state.copyWith(
      modes: [
        for (final m in state.modes)
          EnergyMode(id: m.id, key: m.key, name: m.name, isActive: m.id == modeId),
      ],
    ));
    final r = await _api.activateMode(modeId);
    if (r.isErr) await load(_siteId);
  }
}
