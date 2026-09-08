import 'package:drift/native.dart';
import 'package:ecotrack/core/error/result.dart';
import 'package:ecotrack/data/local/database/app_database.dart';
import 'package:ecotrack/data/local/database/daos/site_dao.dart';
import 'package:ecotrack/data/local/database/daos/sync_dao.dart';
import 'package:ecotrack/data/remote/api/sites_api.dart';
import 'package:ecotrack/data/remote/dto/site_dto.dart';
import 'package:ecotrack/data/repositories/site_repository.dart';
import 'package:ecotrack/domain/entities/site.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements SitesApi {}

SiteDto _dto(String id, String label) =>
    SiteDto(siteId: id, label: label, meterType: 'prepaid');

void main() {
  late AppDatabase db;
  late SiteRepository repo;
  late _MockApi api;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = _MockApi();
    repo = SiteRepository(api, SiteDao(db), SyncDao(db));
  });

  tearDown(() => db.close());

  test('watchSites emits cache first, then the fetched result', () async {
    when(
      api.list,
    ).thenAnswer((_) async => Ok([_dto('s1', 'Home'), _dto('s2', 'Shop')]));

    final emissions = <List<Site>>[];
    final sub = repo.watchSites().listen((r) {
      if (r case Ok(:final value)) emissions.add(value);
    });

    // 1st emission: empty cache. Then the fetch writes through → 2nd emission.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await sub.cancel();

    expect(emissions.first, isEmpty);
    expect(emissions.last.map((s) => s.label), ['Home', 'Shop']);
    verify(api.list).called(1);
  });

  test('does not re-fetch while the cache is fresh', () async {
    when(api.list).thenAnswer((_) async => Ok([_dto('s1', 'Home')]));

    await repo.watchSites().first;
    await Future<void>.delayed(const Duration(milliseconds: 150));

    // Second subscription within the staleness window → no new call.
    await repo.watchSites().first;
    await Future<void>.delayed(const Duration(milliseconds: 150));

    verify(api.list).called(1);
  });

  test('createSite writes through to the cache', () async {
    when(
      () => api.create(any()),
    ).thenAnswer((_) async => Ok(_dto('s9', 'New Site')));

    final r = await repo.createSite({'label': 'New Site'});
    expect(r.isOk, isTrue);

    final cached = await db.select(db.cachedSites).get();
    expect(cached.single.label, 'New Site');
  });
}
