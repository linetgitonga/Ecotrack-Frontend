import 'package:injectable/injectable.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/result.dart';
import '../../../core/network/dio_factory.dart';
import '../dto/user_dto.dart';
import 'api_client.dart';

@lazySingleton
class MeApi {
  MeApi(@Named(DioNames.cloud) this._client);
  final ApiClient _client;

  Future<Result<UserDto>> me() => _client.get<UserDto>(
    ApiPaths.me,
    parse: (d) => UserDto.fromJson(ApiEnvelope.object(d)),
  );

  /// Only `display_name` and `locale` are writable (backend_design.md §3.2).
  Future<Result<UserDto>> updateMe({String? displayName, String? locale}) =>
      _client.patch<UserDto>(
        ApiPaths.me,
        body: {'display_name': ?displayName, 'locale': ?locale},
        parse: (d) => UserDto.fromJson(ApiEnvelope.object(d)),
      );

  // --- Tier B ---------------------------------------------------------
  Future<Result<PreferencesDto>> preferences() => _client.get<PreferencesDto>(
    ApiPaths.mePreferences,
    parse: (d) => PreferencesDto.fromJson(ApiEnvelope.object(d)),
  );

  Future<Result<PreferencesDto>> updatePreferences(PreferencesDto prefs) =>
      _client.put<PreferencesDto>(
        ApiPaths.mePreferences,
        body: prefs.toJson(),
        parse: (d) => PreferencesDto.fromJson(ApiEnvelope.object(d)),
      );
}
