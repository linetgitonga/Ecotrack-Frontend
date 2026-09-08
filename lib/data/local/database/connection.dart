import 'package:drift/drift.dart';

import 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart'
    as impl;

/// Opens the platform database. Native uses a background isolate + SQLite file;
/// web uses the drift WASM worker (wired in Phase 9 — currently a stub).
QueryExecutor openConnection() => impl.openConnection();
