import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/result.dart';
import '../../domain/entities/site.dart';
import '../local/database/app_database.dart';
import '../local/database/daos/site_dao.dart';
import '../local/database/daos/sync_dao.dart';
import '../remote/api/sites_api.dart';
import '../remote/dto/site_dto.dart';
import 'base_repository.dart';

@lazySingleton
class SiteRepository with CacheFirstRepository {
  SiteRepository(this._api, this._dao, this.syncDao);

  final SitesApi _api;
  final SiteDao _dao;
  @override
  final SyncDao syncDao;

  static const _sitesKey = 'sites';
  String _roomsKey(String s) => 'rooms:$s';
  String _membersKey(String s) => 'members:$s';

  // --- Sites -----------------------------------------------------
  Stream<Result<List<Site>>> watchSites({
    void Function(Object failure)? onError,
  }) {
    return watchCached<List<Site>, List<SiteDto>>(
      syncKey: _sitesKey,
      cache: _dao.watchSites().map((rows) => rows.map(_siteFromRow).toList()),
      fetch: _api.list,
      store: (dtos) async {
        await _dao.upsertSites(dtos.map(_siteCompanion).toList());
        await _dao.deleteSitesExcept(dtos.map((d) => d.siteId));
      },
      onRefreshError: (f) => onError?.call(f),
    );
  }

  Future<Result<Unit>> refreshSites() => refresh<List<SiteDto>>(
    syncKey: _sitesKey,
    fetch: _api.list,
    store: (dtos) async {
      await _dao.upsertSites(dtos.map(_siteCompanion).toList());
      await _dao.deleteSitesExcept(dtos.map((d) => d.siteId));
    },
  );

  Stream<Site?> watchSite(String id) =>
      _dao.watchSite(id).map((r) => r == null ? null : _siteFromRow(r));

  Future<Result<Site>> createSite(Map<String, dynamic> body) async {
    final r = await _api.create(body);
    return r.when(
      err: Err<Site>.new,
      ok: (dto) async {
        await _dao.upsertSite(_siteCompanion(dto));
        return Ok(_siteFromDto(dto));
      },
    );
  }

  Future<Result<Site>> updateSite(String id, Map<String, dynamic> body) async {
    final r = await _api.update(id, body);
    return r.when(
      err: Err<Site>.new,
      ok: (dto) async {
        await _dao.upsertSite(_siteCompanion(dto));
        return Ok(_siteFromDto(dto));
      },
    );
  }

  // --- Rooms -------------------------------------------------
  Stream<Result<List<Room>>> watchRooms(String siteId) {
    return watchCached<List<Room>, List<RoomDto>>(
      syncKey: _roomsKey(siteId),
      cache: _dao
          .watchRooms(siteId)
          .map(
            (rows) => rows
                .map(
                  (r) => Room(
                    id: r.id,
                    siteId: r.siteId,
                    name: r.name,
                    type: r.roomType,
                  ),
                )
                .toList(),
          ),
      fetch: () => _api.rooms(siteId),
      store: (dtos) => _dao.replaceRooms(
        siteId,
        dtos
            .map(
              (d) => CachedRoomsCompanion.insert(
                id: d.roomId,
                siteId: siteId,
                name: d.name,
                roomType: Value(d.roomType),
                cachedAt: DateTime.now(),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<Result<Unit>> createRoom(
    String siteId, {
    required String name,
    String? type,
  }) async {
    final r = await _api.createRoom(siteId, {'name': name, 'room_type': ?type});
    if (r.isOk) await refreshRooms(siteId);
    return r.map((_) => Unit.value);
  }

  Future<Result<Unit>> deleteRoom(String siteId, String roomId) async {
    final r = await _api.deleteRoom(roomId);
    if (r.isOk) await refreshRooms(siteId);
    return r;
  }

  Future<Result<Unit>> refreshRooms(String siteId) => refresh<List<RoomDto>>(
    syncKey: _roomsKey(siteId),
    fetch: () => _api.rooms(siteId),
    store: (dtos) => _dao.replaceRooms(
      siteId,
      dtos
          .map(
            (d) => CachedRoomsCompanion.insert(
              id: d.roomId,
              siteId: siteId,
              name: d.name,
              roomType: Value(d.roomType),
              cachedAt: DateTime.now(),
            ),
          )
          .toList(),
    ),
  );

  // --- Members ---------------------------------------------
  Stream<Result<List<SiteMember>>> watchMembers(String siteId) {
    return watchCached<List<SiteMember>, List<MemberDto>>(
      syncKey: _membersKey(siteId),
      cache: _dao
          .watchMembers(siteId)
          .map(
            (rows) => rows
                .map(
                  (r) => SiteMember(
                    id: r.id,
                    userId: r.userId,
                    role: r.role,
                    phoneE164: r.phoneE164,
                    displayName: r.displayName,
                    grantedAt: r.grantedAt,
                  ),
                )
                .toList(),
          ),
      fetch: () => _api.members(siteId),
      store: (dtos) => _dao.replaceMembers(siteId, _memberRows(siteId, dtos)),
    );
  }

  Future<Result<Unit>> inviteMember(
    String siteId, {
    required String phoneE164,
    required String role,
  }) async {
    final r = await _api.invite(siteId, phoneE164: phoneE164, role: role);
    if (r.isOk) await _refreshMembers(siteId);
    return r.map((_) => Unit.value);
  }

  Future<Result<Unit>> changeMemberRole(
    String siteId,
    String userId,
    String role,
  ) async {
    final r = await _api.changeRole(siteId, userId, role);
    if (r.isOk) await _refreshMembers(siteId);
    return r.map((_) => Unit.value);
  }

  /// Caller must have completed step-up immediately before.
  Future<Result<Unit>> removeMember(String siteId, String userId) async {
    final r = await _api.removeMember(siteId, userId);
    if (r.isOk) await _refreshMembers(siteId);
    return r;
  }

  Future<Result<Unit>> _refreshMembers(String siteId) =>
      refresh<List<MemberDto>>(
        syncKey: _membersKey(siteId),
        fetch: () => _api.members(siteId),
        store: (dtos) => _dao.replaceMembers(siteId, _memberRows(siteId, dtos)),
      );

  List<CachedSiteMembersCompanion> _memberRows(
    String siteId,
    List<MemberDto> dtos,
  ) => dtos
      .map(
        (d) => CachedSiteMembersCompanion.insert(
          id: Value(d.id),
          siteId: siteId,
          userId: d.user,
          phoneE164: Value(d.phoneE164),
          displayName: Value(d.displayName),
          role: d.role,
          grantedBy: Value(d.grantedBy),
          grantedAt: Value(d.grantedAt),
          revokedAt: Value(d.revokedAt),
          cachedAt: DateTime.now(),
        ),
      )
      .toList();

  // --- mapping -----------------------------------------------
  Site _siteFromDto(SiteDto d) => Site(
    id: d.siteId,
    label: d.label,
    meterType: Site.meterFromApi(d.meterType),
    timezone: d.timezone,
    status: d.status,
    kplcAccountNo: d.kplcAccountNo,
    kplcMeterNo: d.kplcMeterNo,
    supplyPhase: d.supplyPhase,
    occupantCount: d.occupantCount,
    allowLanCommands: d.allowLanCommands,
    allowCloudCommands: d.allowCloudCommands,
  );

  Site _siteFromRow(CachedSite r) => Site(
    id: r.id,
    label: r.label,
    meterType: Site.meterFromApi(r.meterType),
    timezone: r.timezone,
    status: r.status,
    kplcAccountNo: r.kplcAccountNo,
    kplcMeterNo: r.kplcMeterNo,
    supplyPhase: r.supplyPhase,
    occupantCount: r.occupantCount,
    allowLanCommands: r.allowLanCommands,
    allowCloudCommands: r.allowCloudCommands,
  );

  CachedSitesCompanion _siteCompanion(SiteDto d) => CachedSitesCompanion.insert(
    id: d.siteId,
    tenantId: d.tenantId ?? '',
    label: d.label,
    timezone: Value(d.timezone),
    meterType: d.meterType,
    kplcAccountNo: Value(d.kplcAccountNo),
    kplcMeterNo: Value(d.kplcMeterNo),
    supplyPhase: Value(d.supplyPhase),
    occupantCount: Value(d.occupantCount),
    status: Value(d.status),
    staticIp: Value(d.staticIp),
    localApiPort: Value(d.localApiPort),
    allowLanCommands: Value(d.allowLanCommands),
    allowCloudCommands: Value(d.allowCloudCommands),
    createdAt: Value(d.createdAt),
    cachedAt: DateTime.now(),
  );
}
