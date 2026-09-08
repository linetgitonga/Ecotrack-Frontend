import 'package:injectable/injectable.dart';

import '../../data/remote/api/auth_api.dart';
import '../error/failure.dart';
import '../error/result.dart';
import '../constants/app_constants.dart';

/// Drives the corekit two-call step-up flow for high-consequence actions
/// (member removal, subscription change, hub unclaim, data erasure).
///
///   initiate() → OTP modal → verify(code) → elevated ~300s server-side → retry
@lazySingleton
class StepUpController {
  StepUpController(this._auth);
  final AuthApi _auth;

  String? _pendingToken;
  DateTime? _elevatedUntil;

  /// True while the session is within the server-side elevation window.
  bool get isElevated =>
      _elevatedUntil != null && _elevatedUntil!.isAfter(DateTime.now());

  Future<Result<Unit>> initiate() async {
    final r = await _auth.stepUpInitiate();
    return r.map((challenge) {
      _pendingToken = challenge.pendingToken;
      return Unit.value;
    });
  }

  Future<Result<Unit>> verify(String code) async {
    final token = _pendingToken;
    if (token == null) {
      return const Err(
        UnknownFailure(message: 'Call initiate() before verify()'),
      );
    }
    final r = await _auth.stepUpVerify(pendingToken: token, code: code);
    return r.map((_) {
      _elevatedUntil = DateTime.now().add(AppConstants.stepUpElevationWindow);
      _pendingToken = null;
      return Unit.value;
    });
  }

  void reset() {
    _pendingToken = null;
    _elevatedUntil = null;
  }
}
