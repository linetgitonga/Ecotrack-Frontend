import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Periodic background sync via `workmanager` (Android WorkManager / iOS
/// BGTaskScheduler — best-effort on iOS). Web has no equivalent; the foreground
/// poll in `SyncEngine` is the fallback there.
///
/// The callback runs in a **separate isolate** with no access to the app's DI
/// graph, so it does a minimal, self-contained sync: open the DB, drain the
/// outbox, close. Wired fully in a later phase; this establishes the entrypoint.
abstract final class BackgroundSync {
  static const _taskName = 'ecotrack.periodic-sync';
  static const _uniqueName = 'ecotrack.periodic-sync.unique';

  static Future<void> register() async {
    if (kIsWeb) return;
    await Workmanager().initialize(_dispatcher);
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      _taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static Future<void> cancel() => Workmanager().cancelAll();
}

/// Top-level entrypoint required by workmanager (must be a top-level or static
/// function annotated for the separate isolate).
@pragma('vm:entry-point')
void _dispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // TODO(phase-6): open AppDatabase directly, drain the outbox, upload
    // rollups/health. Keep this isolate-safe (no getIt).
    return true;
  });
}
