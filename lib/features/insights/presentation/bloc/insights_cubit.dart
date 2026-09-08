import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/error_messages.dart';
import '../../../../data/remote/api/tierb_api.dart';

class InsightsState extends Equatable {
  const InsightsState({
    this.loading = true,
    this.cost,
    this.breakdown = const [],
    this.trend = const [],
    this.recommendations = const [],
    this.error,
  });

  final bool loading;
  final CostSummary? cost;
  final List<CostSlice> breakdown;
  final List<double> trend;
  final List<Recommendation> recommendations;
  final String? error;

  InsightsState copyWith({
    bool? loading,
    CostSummary? cost,
    List<CostSlice>? breakdown,
    List<double>? trend,
    List<Recommendation>? recommendations,
    Object? error = _s,
  }) =>
      InsightsState(
        loading: loading ?? this.loading,
        cost: cost ?? this.cost,
        breakdown: breakdown ?? this.breakdown,
        trend: trend ?? this.trend,
        recommendations: recommendations ?? this.recommendations,
        error: identical(error, _s) ? this.error : error as String?,
      );

  static const _s = Object();

  @override
  List<Object?> get props =>
      [loading, cost, breakdown, trend, recommendations, error];
}

@injectable
class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit(this._api) : super(const InsightsState());
  final TierBApi _api;
  String _siteId = '';

  Future<void> load(String siteId) async {
    _siteId = siteId;
    emit(state.copyWith(loading: true, error: null));
    final results = await Future.wait([
      _api.costSummary(_siteId),
      _api.costBreakdown(_siteId),
      _api.costSeries(_siteId),
      _api.insights(_siteId),
    ]);

    final cost = (results[0] as dynamic).valueOrNull as CostSummary?;
    final breakdown =
        (results[1] as dynamic).valueOrNull as List<CostSlice>? ?? const [];
    final trend =
        (results[2] as dynamic).valueOrNull as List<double>? ?? const [];
    final recs =
        (results[3] as dynamic).valueOrNull as List<Recommendation>? ?? const [];

    if (cost == null && breakdown.isEmpty) {
      emit(state.copyWith(
        loading: false,
        error: ErrorMessages.forFailure((results[0] as dynamic).failureOrNull),
      ));
      return;
    }
    emit(InsightsState(
      loading: false,
      cost: cost,
      breakdown: breakdown,
      trend: trend,
      recommendations: recs,
    ));
  }
}
