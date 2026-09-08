import 'package:drift/drift.dart';

/// Web database — the drift WASM worker + `sqlite3.wasm` asset are wired in
/// Phase 9 (web dashboard). Until then the web build compiles but the DB is not
/// usable; the web dashboard is cloud-transport-only and not yet shipped.
QueryExecutor openConnection() {
  throw UnsupportedError(
    'The on-device database is not available on web yet (Phase 9). '
    'Load ecotrack on Android or iOS.',
  );
}
