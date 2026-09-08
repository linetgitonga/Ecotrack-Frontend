import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../data/local/database/app_database.dart';
import '../../data/local/database/daos/sync_dao.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Sends one queued outbox item. A handler is registered per `kind`; the
/// processor manages ordering, backoff, expiry and dedup — handlers just do the
/// network call and return a [Result].
typedef OutboxHandler =
    Future<Result<void>> Function(Map<String, dynamic> payload);

@lazySingleton
class OutboxProcessor {
  OutboxProcessor(this._db, this._sync);

  final AppDatabase _db;
  final SyncDao _sync;
  final _handlers = <String, OutboxHandler>{};

  void register(String kind, OutboxHandler handler) =>
      _handlers[kind] = handler;

  /// Drain every due item once, highest priority first. Returns how many
  /// were sent. Safe to call repeatedly.
  Future<int> drain() async {
    final due = await _sync.dueItems();
    var sent = 0;

    for (final item in due) {
      // Expired queued command → drop, never fire late (Database_Design §1.9).
      if (item.expiresAt != null && item.expiresAt!.isBefore(DateTime.now())) {
        await _sync.deleteOutboxItem(item.seq);
        continue;
      }

      final handler = _handlers[item.kind];
      if (handler == null) continue;

      final payload = _decode(item.payload);
      final result = await handler(payload);

      await result.when(
        ok: (_) async {
          await _sync.deleteOutboxItem(item.seq);
          if (item.idempotencyKey != null) {
            await _db
                .into(_db.commandDedup)
                .insertOnConflictUpdate(
                  CommandDedupCompanion.insert(
                    idempotencyKey: item.idempotencyKey!,
                    appliedAt: DateTime.now(),
                  ),
                );
          }
          sent++;
        },
        err: (f) async {
          // Permanent failures shouldn't retry forever.
          if (_isPermanent(f) || item.attempts >= 8) {
            await _sync.deleteOutboxItem(item.seq);
          } else {
            await _sync.markAttempt(
              item.seq,
              nextTryAt: _backoff(item.attempts),
              error: f.toString(),
            );
          }
        },
      );
    }
    return sent;
  }

  bool _isPermanent(Failure f) =>
      f is ValidationFailure || f is ForbiddenFailure || f is ConflictFailure;

  DateTime _backoff(int attempts) {
    final seconds = (1 << attempts.clamp(0, 6)).clamp(1, 300) * 60;
    return DateTime.now().add(Duration(seconds: seconds));
  }

  Map<String, dynamic> _decode(String s) {
    try {
      final v = jsonDecode(s);
      return v is Map ? v.cast<String, dynamic>() : const {};
    } catch (_) {
      return const {};
    }
  }
}
