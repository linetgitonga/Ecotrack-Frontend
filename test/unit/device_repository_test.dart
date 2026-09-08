import 'package:drift/native.dart';
import 'package:ecotrack/core/connectivity/connection_manager.dart';
import 'package:ecotrack/core/connectivity/connection_state.dart';
import 'package:ecotrack/core/error/failure.dart';
import 'package:ecotrack/core/error/result.dart';
import 'package:ecotrack/data/local/database/app_database.dart';
import 'package:ecotrack/data/local/database/daos/device_dao.dart';
import 'package:ecotrack/data/local/database/daos/sync_dao.dart';
import 'package:ecotrack/data/remote/api/tierb_api.dart';
import 'package:ecotrack/data/repositories/device_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockApi extends Mock implements TierBApi {}

class _MockConn extends Mock implements ConnectionManager {}

void main() {
  late AppDatabase db;
  late DeviceRepository repo;
  late _MockApi api;
  late _MockConn conn;
  late SyncDao sync;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = _MockApi();
    conn = _MockConn();
    sync = SyncDao(db);
    repo = DeviceRepository(api, DeviceDao(db), sync, conn, const Uuid());

    // seed one cached device
    await DeviceDao(db).replaceForSite('s1', [_companion('d1', 's1')]);
  });

  tearDown(() => db.close());

  test('online toggle sends the command', () async {
    when(() => conn.current).thenReturn(
      EcoConnection(mode: ConnectionMode.cloud, since: DateTime.now()),
    );
    when(
      () => api.sendCommand(
        'd1',
        on: any(named: 'on'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((_) async => const Ok(Unit.value));

    final r = await repo.setPower('d1', true);
    expect(r.valueOrNull, CommandOutcome.sent);
    expect(await sync.dueItems(), isEmpty);
  });

  test('offline toggle queues to the outbox with an idempotency key', () async {
    when(() => conn.current).thenReturn(EcoConnection.offline());

    final r = await repo.setPower('d1', true);
    expect(r.valueOrNull, CommandOutcome.queued);

    final due = await sync.dueItems();
    expect(due, hasLength(1));
    expect(due.single.kind, 'command');
    expect(due.single.idempotencyKey, isNotNull);
    verifyNever(
      () => api.sendCommand(
        any(),
        on: any(named: 'on'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    );
  });

  test('network failure on send falls back to the outbox', () async {
    when(() => conn.current).thenReturn(
      EcoConnection(mode: ConnectionMode.cloud, since: DateTime.now()),
    );
    when(
      () => api.sendCommand(
        'd1',
        on: any(named: 'on'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    final r = await repo.setPower('d1', true);
    expect(r.valueOrNull, CommandOutcome.queued);
    expect(await sync.dueItems(), hasLength(1));
  });

  test('permanent failure rolls back the optimistic flip', () async {
    when(() => conn.current).thenReturn(
      EcoConnection(mode: ConnectionMode.cloud, since: DateTime.now()),
    );
    when(
      () => api.sendCommand(
        'd1',
        on: any(named: 'on'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer(
      (_) async => const Err(ConflictFailure(message: 'Critical appliance')),
    );

    final r = await repo.setPower('d1', true);
    expect(r.isErr, isTrue);
    final row = await (db.select(
      db.cachedDevices,
    )..where((t) => t.id.equals('d1'))).getSingle();
    expect(row.relayState, isFalse); // rolled back
  });
}

dynamic _companion(String id, String siteId) => CachedDevicesCompanion.insert(
  id: id,
  siteId: siteId,
  name: id,
  deviceClass: 'smart_plug',
  cachedAt: DateTime.now(),
);
