import 'package:injectable/injectable.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/result.dart';
import '../../../core/network/dio_factory.dart';
import 'api_client.dart';

/// Consent + data-rights endpoints (System_Design §8.1, Kenya DPA 2019). Tier B.
@lazySingleton
class AccountApi {
  AccountApi(@Named(DioNames.cloud) this._client);
  final ApiClient _client;

  Future<Result<Map<String, bool>>> consents() =>
      _client.get<Map<String, bool>>(
        ApiPaths.meConsents,
        parse: (d) => {
          for (final e in ApiEnvelope.list(d))
            e['purpose'].toString(): e['granted'] == true,
        },
      );

  Future<Result<Unit>> setConsent(String purpose, bool granted) async {
    final r = await _client.put<Object?>(
      ApiPaths.meConsent(purpose),
      body: {'granted': granted},
      parse: (d) => d,
    );
    return r.map((_) => Unit.value);
  }

  /// DPA 2019 subject access request. Async — the server emails a link.
  Future<Result<String>> requestDataExport() => _client.get<String>(
    ApiPaths.meDataExport,
    parse: (d) =>
        ApiEnvelope.object(d)['message']?.toString() ??
        'Your data export request has been received.',
  );

  /// DPA 2019 erasure request — step-up must have been completed first.
  Future<Result<String>> requestDataErasure() => _client.post<String>(
    ApiPaths.meDataErasure,
    body: const {},
    parse: (d) =>
        ApiEnvelope.object(d)['message']?.toString() ??
        'Your erasure request has been logged.',
  );
}
