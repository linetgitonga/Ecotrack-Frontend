import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../app_database.dart';
import '../tables/sync_tables.dart';

part 'sync_dao.g.dart';

/// Staleness tracking + outbox access. Repositories use [isStale] to decide
/// whether to revalidate a cache-first read.
@lazySingleton
@DriftAccessor(tables: [SyncMeta, Outbox, CommandDedup])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  Future<DateTime?> lastSyncedAt(String key) async {
    final row = await (select(
      syncMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.lastSyncedAt;
  }

  Future<bool> isStale(String key, {Duration? maxAge}) async {
    final at = await lastSyncedAt(key);
    if (at == null) return true;
    return DateTime.now().difference(at) >
        (maxAge ?? AppConstants.defaultStaleness);
  }

  Future<void> markSynced(String key, {String? cursor}) {
    return into(syncMeta).insertOnConflictUpdate(
      SyncMetaCompanion(
        key: Value(key),
        lastSyncedAt: Value(DateTime.now()),
        cursor: Value.absentIfNull(cursor),
      ),
    );
  }

  // --- Outbox -----------------------------------------------------
  Future<int> enqueue({
    required String kind,
    required String payload,
    int priority = 0,
    String? idempotencyKey,
    DateTime? expiresAt,
  }) {
    return into(outbox).insert(
      OutboxCompanion.insert(
        kind: kind,
        payload: payload,
        priority: Value(priority),
        idempotencyKey: Value.absentIfNull(idempotencyKey),
        createdAt: DateTime.now(),
        nextTryAt: Value(DateTime.now()),
        expiresAt: Value.absentIfNull(expiresAt),
      ),
    );
  }

  /// Pending items due for a send attempt, highest priority first.
  Future<List<OutboxData>> dueItems({DateTime? now}) {
    final ts = now ?? DateTime.now();
    return (select(outbox)
          ..where(
            (t) => t.nextTryAt.isSmallerOrEqualValue(ts) | t.nextTryAt.isNull(),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.priority),
            (t) => OrderingTerm.asc(t.seq),
          ]))
        .get();
  }

  Stream<int> watchPendingCount() {
    final q = selectOnly(outbox)..addColumns([outbox.seq.count()]);
    return q.map((r) => r.read(outbox.seq.count()) ?? 0).watchSingle();
  }

  Future<void> deleteOutboxItem(int seq) =>
      (delete(outbox)..where((t) => t.seq.equals(seq))).go();

  /// Record a failed send: bump `attempts`, back off `nextTryAt`, keep the error.
  Future<void> markAttempt(
    int seq, {
    required DateTime nextTryAt,
    String? error,
  }) {
    return customUpdate(
      'UPDATE outbox SET attempts = attempts + 1, next_try_at = ?, last_error = ? '
      'WHERE seq = ?',
      variables: [
        Variable.withDateTime(nextTryAt),
        Variable.withString(error ?? ''),
        Variable.withInt(seq),
      ],
      updates: {outbox},
    );
  }
}
