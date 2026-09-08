import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../app_database.dart';
import '../tables/device_tables.dart';

part 'device_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [CachedDevices, CachedRollups])
class DeviceDao extends DatabaseAccessor<AppDatabase> with _$DeviceDaoMixin {
  DeviceDao(super.db);

  Stream<List<CachedDevice>> watchDevices(String siteId) =>
      (select(cachedDevices)
            ..where((t) => t.siteId.equals(siteId))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<List<CachedDevice>> devices(String siteId) =>
      (select(cachedDevices)..where((t) => t.siteId.equals(siteId))).get();

  Stream<CachedDevice?> watchDevice(String id) => (select(
    cachedDevices,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<void> replaceForSite(
    String siteId,
    List<CachedDevicesCompanion> rows,
  ) async {
    await transaction(() async {
      await (delete(cachedDevices)..where((t) => t.siteId.equals(siteId))).go();
      await batch((b) => b.insertAll(cachedDevices, rows));
    });
  }

  /// Merge live readings (watts/relay/reachable) without disturbing metadata.
  Future<void> applyLive(
    Iterable<({String id, double watts, bool relay, bool reachable})> live,
  ) async {
    await batch((b) {
      for (final l in live) {
        b.update(
          cachedDevices,
          CachedDevicesCompanion(
            watts: Value(l.watts),
            relayState: Value(l.relay),
            reachable: Value(l.reachable),
            cachedAt: Value(DateTime.now()),
          ),
          where: (t) => t.id.equals(l.id),
        );
      }
    });
  }

  /// Optimistic local flip for a queued command.
  Future<void> setRelay(String id, bool on) =>
      (update(cachedDevices)..where((t) => t.id.equals(id))).write(
        CachedDevicesCompanion(relayState: Value(on)),
      );

  Future<void> upsertRollups(List<CachedRollupsCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(cachedRollups, rows));

  Future<List<CachedRollup>> rollups(String deviceId) =>
      (select(cachedRollups)
            ..where((t) => t.deviceId.equals(deviceId))
            ..orderBy([(t) => OrderingTerm.asc(t.hour)]))
          .get();
}
