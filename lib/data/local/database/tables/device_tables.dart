import 'package:drift/drift.dart';

/// Cached `/devices` + `/telemetry/live` — last-known device state so Home and
/// Devices render offline (Database_Design §1.3 device_current_state / edge
/// local_state). `reachable` is stored distinct from `relayState` (§2.3).
class CachedDevices extends Table {
  TextColumn get id => text()();
  TextColumn get siteId => text()();
  TextColumn get name => text()();
  TextColumn get deviceClass => text()();
  TextColumn get roomId => text().nullable()();
  TextColumn get roomName => text().nullable()();
  BoolColumn get relayState => boolean().withDefault(const Constant(false))();
  BoolColumn get reachable => boolean().withDefault(const Constant(true))();
  BoolColumn get switchable => boolean().withDefault(const Constant(true))();
  RealColumn get watts => real().withDefault(const Constant(0))();
  RealColumn get volts => real().nullable()();
  RealColumn get amps => real().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local ring of hourly rollups for the 24h/7d/30d device charts offline
/// (edge `rollup_hourly`). Keyed by device + hour.
class CachedRollups extends Table {
  TextColumn get deviceId => text()();
  DateTimeColumn get hour => dateTime()();
  RealColumn get energyWh => real().withDefault(const Constant(0))();
  RealColumn get avgWatts => real().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId, hour};
}
