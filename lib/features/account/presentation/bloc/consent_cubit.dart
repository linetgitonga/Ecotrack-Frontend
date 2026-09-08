import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/auth/step_up_controller.dart';
import '../../../../core/constants/error_messages.dart';
import '../../../../core/error/result.dart';
import '../../../../data/remote/api/account_api.dart';

/// Consent purposes from `consent_records` (Database_Design §1.10). The order
/// here is the display order. `service_delivery` is required (non-toggle).
enum ConsentPurpose {
  serviceDelivery('service_delivery', 'Run the service', true),
  occupancyAnalytics('occupancy_analytics', 'Occupancy analytics', false),
  nilmDisaggregation(
    'nilm_disaggregation',
    'Appliance-level breakdown (NILM)',
    false,
  ),
  researchAggregate('research_aggregate', 'Anonymous research', false),
  marketing('marketing', 'Product updates & offers', false),
  thirdPartySharing('third_party_sharing', 'Share with partners', false);

  const ConsentPurpose(this.key, this.label, this.required);
  final String key;
  final String label;
  final bool required;

  String get description => switch (this) {
    serviceDelivery =>
      'Store your meter readings and account so the app works. Required.',
    occupancyAnalytics =>
      'Use energy patterns to detect when your home is empty for the Away '
          'features. This data reveals occupancy.',
    nilmDisaggregation =>
      'Analyse whole-home data to estimate which appliances use what.',
    researchAggregate =>
      'Include your anonymised usage in aggregate energy research.',
    marketing => 'Contact you about new features and offers.',
    thirdPartySharing =>
      'Share data with third parties (e.g. utilities, insurers). Off by '
          'default.',
  };
}

class ConsentState extends Equatable {
  const ConsentState({
    this.loading = true,
    this.granted = const {},
    this.saving,
    this.error,
    this.requestResult,
  });

  final bool loading;
  final Map<String, bool> granted;
  final String? saving; // purpose key currently being written
  final String? error;
  final String? requestResult; // export/erasure confirmation message

  bool isGranted(ConsentPurpose p) => p.required || (granted[p.key] ?? false);

  ConsentState copyWith({
    bool? loading,
    Map<String, bool>? granted,
    Object? saving = _s,
    Object? error = _s,
    Object? requestResult = _s,
  }) => ConsentState(
    loading: loading ?? this.loading,
    granted: granted ?? this.granted,
    saving: identical(saving, _s) ? this.saving : saving as String?,
    error: identical(error, _s) ? this.error : error as String?,
    requestResult: identical(requestResult, _s)
        ? this.requestResult
        : requestResult as String?,
  );

  static const _s = Object();

  @override
  List<Object?> get props => [loading, granted, saving, error, requestResult];
}

@injectable
class ConsentCubit extends Cubit<ConsentState> {
  ConsentCubit(this._api, this._stepUp) : super(const ConsentState());
  final AccountApi _api;
  final StepUpController _stepUp;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    final r = await _api.consents();
    r.when(
      ok: (m) => emit(ConsentState(loading: false, granted: m)),
      err: (f) => emit(
        state.copyWith(loading: false, error: ErrorMessages.forFailure(f)),
      ),
    );
  }

  Future<void> setConsent(ConsentPurpose p, bool granted) async {
    if (p.required) return;
    emit(
      state.copyWith(
        saving: p.key,
        granted: {...state.granted, p.key: granted},
      ),
    );
    final r = await _api.setConsent(p.key, granted);
    if (r.isErr) {
      emit(
        state.copyWith(
          saving: null,
          granted: {...state.granted, p.key: !granted},
          error: ErrorMessages.forFailure(r.failureOrNull!),
        ),
      );
    } else {
      emit(state.copyWith(saving: null));
    }
  }

  Future<void> requestExport() async {
    final r = await _api.requestDataExport();
    emit(
      state.copyWith(
        requestResult: r.valueOrNull,
        error: r.isErr ? ErrorMessages.forFailure(r.failureOrNull!) : null,
      ),
    );
  }

  /// Step-up step 1 (UI shows the OTP modal).
  Future<Result<Unit>> beginErasure() => _stepUp.initiate();

  /// Step-up step 2 + the erasure request.
  Future<Result<Unit>> confirmErasure(String code) async {
    final verified = await _stepUp.verify(code);
    if (verified.isErr) return verified;
    final r = await _api.requestDataErasure();
    return r.when(
      ok: (msg) {
        emit(state.copyWith(requestResult: msg));
        return const Ok(Unit.value);
      },
      err: Err<Unit>.new,
    );
  }
}
