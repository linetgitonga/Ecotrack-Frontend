import 'package:drift/drift.dart';

/// Staleness bookkeeping — one row per cache key (`devices:<siteId>`, `sites`,
/// …). Drives the cache-first / revalidate flow (plan §2.2).
class SyncMeta extends Table {
  TextColumn get key => text()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Server pagination cursor / ETag when applicable.
  TextColumn get cursor => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Uplink queue — local writes waiting to sync (mirrors the edge `outbox`).
/// Drained by the sync engine in priority order; `expiresAt` is honoured so a
/// stale "switch off" never fires late.
class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();

  /// rollup | health | alert_ack | mode | state | command | config | log
  TextColumn get kind => text()();

  /// JSON payload for the handler.
  TextColumn get payload => text()();

  /// Higher drains first: alert_ack(30) > mode/state(20) > config(10) > rest(0).
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// Reused across retries and across LAN+cloud so the server dedupes.
  TextColumn get idempotencyKey => text().nullable()();

  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get nextTryAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
}

/// Local dedup for commands sent over both transports concurrently.
class CommandDedup extends Table {
  TextColumn get idempotencyKey => text()();
  DateTimeColumn get appliedAt => dateTime()();
  TextColumn get result => text().nullable()();

  @override
  Set<Column> get primaryKey => {idempotencyKey};
}
