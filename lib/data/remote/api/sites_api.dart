import 'package:injectable/injectable.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/result.dart';
import '../../../core/network/dio_factory.dart';
import '../dto/site_dto.dart';
import 'api_client.dart';

/// Tier A — sites / rooms / members (backend_design.md §3.3–3.5).
/// List endpoints return **bare arrays** (no pagination).
@lazySingleton
class SitesApi {
  SitesApi(@Named(DioNames.cloud) this._client);
  final ApiClient _client;

  Future<Result<List<SiteDto>>> list() => _client.get<List<SiteDto>>(
    ApiPaths.sites,
    parse: (d) => ApiEnvelope.list(d).map(SiteDto.fromJson).toList(),
  );

  Future<Result<SiteDto>> get(String id) => _client.get<SiteDto>(
    ApiPaths.site(id),
    parse: (d) => SiteDto.fromJson(ApiEnvelope.object(d)),
  );

  Future<Result<SiteDto>> create(Map<String, dynamic> body) =>
      _client.post<SiteDto>(
        ApiPaths.sites,
        body: body,
        parse: (d) => SiteDto.fromJson(ApiEnvelope.object(d)),
      );

  Future<Result<SiteDto>> update(String id, Map<String, dynamic> body) =>
      _client.patch<SiteDto>(
        ApiPaths.site(id),
        body: body,
        parse: (d) => SiteDto.fromJson(ApiEnvelope.object(d)),
      );

  // --- Rooms --------------------------------------------------------
  Future<Result<List<RoomDto>>> rooms(String siteId) =>
      _client.get<List<RoomDto>>(
        ApiPaths.siteRooms(siteId),
        parse: (d) => ApiEnvelope.list(d).map(RoomDto.fromJson).toList(),
      );

  Future<Result<RoomDto>> createRoom(
    String siteId,
    Map<String, dynamic> body,
  ) => _client.post<RoomDto>(
    ApiPaths.siteRooms(siteId),
    body: body,
    parse: (d) => RoomDto.fromJson(ApiEnvelope.object(d)),
  );

  Future<Result<RoomDto>> updateRoom(
    String roomId,
    Map<String, dynamic> body,
  ) => _client.patch<RoomDto>(
    ApiPaths.room(roomId),
    body: body,
    parse: (d) => RoomDto.fromJson(ApiEnvelope.object(d)),
  );

  Future<Result<Unit>> deleteRoom(String roomId) =>
      _client.delete(ApiPaths.room(roomId));

  // --- Members -----------------------------------------------------
  Future<Result<List<MemberDto>>> members(String siteId) =>
      _client.get<List<MemberDto>>(
        ApiPaths.siteMembers(siteId),
        parse: (d) => ApiEnvelope.list(d).map(MemberDto.fromJson).toList(),
      );

  Future<Result<MemberDto>> invite(
    String siteId, {
    required String phoneE164,
    required String role,
  }) => _client.post<MemberDto>(
    ApiPaths.siteMembers(siteId),
    body: {'phone_e164': phoneE164, 'role': role},
    parse: (d) => MemberDto.fromJson(ApiEnvelope.object(d)),
  );

  Future<Result<MemberDto>> changeRole(
    String siteId,
    String userId,
    String role,
  ) => _client.patch<MemberDto>(
    ApiPaths.siteMember(siteId, userId),
    body: {'role': role},
    parse: (d) => MemberDto.fromJson(ApiEnvelope.object(d)),
  );

  /// Requires step-up MFA to have been completed immediately before.
  Future<Result<Unit>> removeMember(String siteId, String userId) =>
      _client.delete(ApiPaths.siteMember(siteId, userId));
}
