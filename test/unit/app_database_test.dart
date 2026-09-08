import 'package:drift/native.dart';
import 'package:ecotrack/data/local/database/app_database.dart';
import 'package:ecotrack/data/local/database/daos/sync_dao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SyncDao sync;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sync = SyncDao(db);
  });

  tearDown(() => db.close());

  test('schema creates and opens (schemaVersion 1)', () async {
    expect(db.schemaVersion, 1);
    // A trivial query proves every table was created.
    expect(await db.select(db.cachedSites).get(), isEmpty);
  });

  group('SyncDao staleness', () {
    test('unknown key is stale', () async {
      expect(await sync.isStale('sites'), isTrue);
    });

    test('markSynced clears staleness within the window', () async {
      await sync.markSynced('sites');
      expect(await sync.isStale('sites'), isFalse);
      expect(await sync.isStale('sites', maxAge: Duration.zero), isTrue);
    });
  });

  group('outbox', () {
    test('enqueue → dueItems ordered by priority then seq', () async {
      await sync.enqueue(kind: 'log', payload: '{}', priority: 0);
      await sync.enqueue(kind: 'alert_ack', payload: '{"id":1}', priority: 30);
      await sync.enqueue(kind: 'mode', payload: '{}', priority: 20);

      final due = await sync.dueItems();
      expect(due.map((e) => e.kind), ['alert_ack', 'mode', 'log']);
    });

    test('markAttempt bumps attempts and backs off nextTryAt', () async {
      final seq = await sync.enqueue(kind: 'command', payload: '{}');
      final future = DateTime.now().add(const Duration(minutes: 5));
      await sync.markAttempt(seq, nextTryAt: future, error: 'boom');

      final due = await sync.dueItems(); // nothing due yet
      expect(due, isEmpty);
      final all = await db.select(db.outbox).get();
      expect(all.single.attempts, 1);
      expect(all.single.lastError, 'boom');
    });

    test('watchPendingCount emits', () async {
      expectLater(sync.watchPendingCount(), emitsThrough(2));
      await sync.enqueue(kind: 'a', payload: '{}');
      await sync.enqueue(kind: 'b', payload: '{}');
    });
  });

  test('clearUserData wipes cache + outbox', () async {
    await db
        .into(db.cachedSites)
        .insert(
          CachedSitesCompanion.insert(
            id: 's1',
            tenantId: 't1',
            label: 'Home',
            meterType: 'prepaid',
            cachedAt: DateTime.now(),
          ),
        );
    await sync.enqueue(kind: 'x', payload: '{}');
    await sync.markSynced('sites');

    await db.clearUserData();

    expect(await db.select(db.cachedSites).get(), isEmpty);
    expect(await db.select(db.outbox).get(), isEmpty);
    expect(await sync.isStale('sites'), isTrue);
  });
}
