import 'dart:async';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../local/database/daos/sync_dao.dart';

/// Shared cache-first / revalidate machinery (plan §2.2).
///
/// A read-repository method calls [watchCached] with:
///   * a DB stream (the source of truth for the UI),
///   * a `syncKey` for staleness bookkeeping,
///   * a `fetch` that hits the API and returns DTOs,
///   * a `store` that write-throughs those DTOs (the DB stream re-emits).
///
/// The cache is emitted immediately; the network refresh runs as a side effect
/// and its failure is surfaced without discarding the cache.
mixin CacheFirstRepository {
  SyncDao get syncDao;

  Stream<Result<T>> watchCached<T, D>({
    required String syncKey,
    required Stream<T> cache,
    required Future<Result<D>> Function() fetch,
    required Future<void> Function(D data) store,
    Duration? maxAge,
    void Function(Failure failure)? onRefreshError,
    void Function()? onRefreshOk,
  }) {
    // Fire-and-forget revalidation; errors go to [onRefreshError].
    unawaited(
      _revalidate(
        syncKey: syncKey,
        fetch: fetch,
        store: store,
        maxAge: maxAge,
        onError: onRefreshError,
        onOk: onRefreshOk,
      ),
    );

    return cache
        .map<Result<T>>(Result.ok)
        .handleError(
          (Object e, StackTrace st) => Err<T>(CacheFailure(cause: e)),
        );
  }

  /// One-shot refresh (pull-to-refresh, or forced).
  Future<Result<Unit>> refresh<D>({
    required String syncKey,
    required Future<Result<D>> Function() fetch,
    required Future<void> Function(D data) store,
  }) async {
    final r = await fetch();
    return r.when(
      ok: (data) async {
        await store(data);
        await syncDao.markSynced(syncKey);
        return const Ok(Unit.value);
      },
      err: (f) => Err<Unit>(f),
    );
  }

  Future<void> _revalidate<D>({
    required String syncKey,
    required Future<Result<D>> Function() fetch,
    required Future<void> Function(D data) store,
    Duration? maxAge,
    void Function(Failure failure)? onError,
    void Function()? onOk,
  }) async {
    if (!await syncDao.isStale(syncKey, maxAge: maxAge)) return;
    final r = await fetch();
    await r.when(
      ok: (data) async {
        await store(data);
        await syncDao.markSynced(syncKey);
        onOk?.call();
      },
      err: (f) async => onError?.call(f),
    );
  }
}
