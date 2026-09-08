import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../app_database.dart';
import '../tables/identity_tables.dart';

part 'site_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [CachedSites, CachedRooms, CachedSiteMembers])
class SiteDao extends DatabaseAccessor<AppDatabase> with _$SiteDaoMixin {
  SiteDao(super.db);

  // --- Sites -------------------------------------------------------
  Stream<List<CachedSite>> watchSites() => (select(
    cachedSites,
  )..orderBy([(t) => OrderingTerm.asc(t.label)])).watch();

  Stream<CachedSite?> watchSite(String id) =>
      (select(cachedSites)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<void> upsertSites(List<CachedSitesCompanion> rows) async {
    await batch((b) {
      for (final r in rows) {
        b.insert(cachedSites, r, onConflict: DoUpdate((_) => r));
      }
    });
  }

  Future<void> upsertSite(CachedSitesCompanion row) =>
      into(cachedSites).insertOnConflictUpdate(row);

  Future<void> deleteSitesExcept(Iterable<String> keepIds) async {
    await (delete(cachedSites)..where((t) => t.id.isNotIn(keepIds))).go();
  }

  // --- Rooms -----------------------------------------------------
  Stream<List<CachedRoom>> watchRooms(String siteId) =>
      (select(cachedRooms)
            ..where((t) => t.siteId.equals(siteId))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<void> replaceRooms(
    String siteId,
    List<CachedRoomsCompanion> rows,
  ) async {
    await transaction(() async {
      await (delete(cachedRooms)..where((t) => t.siteId.equals(siteId))).go();
      await batch((b) => b.insertAll(cachedRooms, rows));
    });
  }

  // --- Members -------------------------------------------------
  Stream<List<CachedSiteMember>> watchMembers(String siteId) => (select(
    cachedSiteMembers,
  )..where((t) => t.siteId.equals(siteId) & t.revokedAt.isNull())).watch();

  Future<void> replaceMembers(
    String siteId,
    List<CachedSiteMembersCompanion> rows,
  ) async {
    await transaction(() async {
      await (delete(
        cachedSiteMembers,
      )..where((t) => t.siteId.equals(siteId))).go();
      await batch((b) => b.insertAll(cachedSiteMembers, rows));
    });
  }
}
