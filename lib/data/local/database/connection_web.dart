import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

/// Web database — drift on `sqlite3.wasm` with a shared worker for OPFS/IndexedDB
/// persistence. The two assets (`web/sqlite3.wasm`, `web/drift_worker.js`) are
/// checked into `web/`.
///
/// If persistence isn't available (private window, old browser) drift falls back
/// to an in-memory database automatically — the web dashboard is cloud-first, so
/// a cold cache just means one extra fetch.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'ecotrack',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty && kDebugMode) {
      debugPrint(
        'drift/web: degraded persistence (${result.missingFeatures}) — '
        'using ${result.chosenImplementation}',
      );
    }
    return result.resolvedExecutor;
  });
}
