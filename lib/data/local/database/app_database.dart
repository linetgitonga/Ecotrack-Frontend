import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'connection.dart';
import 'tables/device_tables.dart';
import 'tables/identity_tables.dart';
import 'tables/sync_tables.dart';

part 'app_database.g.dart';

/// The on-device cache + outbox. Shaped like the edge store (Database_Design
/// Part 2) plus the cloud entities the UI lists — not a copy of the cloud schema.
///
/// More table groups (devices, telemetry, automation, alerts, tariff, account)
/// are added in later phases; each bumps [schemaVersion] with a migration step.
@lazySingleton
@DriftDatabase(
  tables: [
    // sync
    SyncMeta,
    Outbox,
    CommandDedup,
    // identity
    CachedUsers,
    CachedSites,
    CachedRooms,
    CachedSiteMembers,
    // devices
    CachedDevices,
    CachedRollups,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Test constructor — pass an in-memory / mock executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(cachedDevices);
        await m.createTable(cachedRollups);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  /// Wipe user-scoped cache on logout / revoke-all. The outbox is also cleared:
  /// queued writes belong to the session that made them.
  Future<void> clearUserData() async {
    await batch((b) {
      b.deleteAll(cachedUsers);
      b.deleteAll(cachedSites);
      b.deleteAll(cachedRooms);
      b.deleteAll(cachedSiteMembers);
      b.deleteAll(cachedDevices);
      b.deleteAll(cachedRollups);
      b.deleteAll(outbox);
      b.deleteAll(commandDedup);
      b.deleteAll(syncMeta);
    });
  }
}
