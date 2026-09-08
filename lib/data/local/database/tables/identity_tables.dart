import 'package:drift/drift.dart';

/// Cached `/me`. Single row (`id` is the user uuid).
class CachedUsers extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get phoneE164 => text()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().nullable()();

  /// owner | member | viewer | installer  (tenant-wide)
  TextColumn get role => text()();
  TextColumn get locale => text().withDefault(const Constant('en-KE'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached `/sites`.
class CachedSites extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get label => text()();
  TextColumn get timezone =>
      text().withDefault(const Constant('Africa/Nairobi'))();
  TextColumn get meterType => text()(); // prepaid | postpaid
  TextColumn get kplcAccountNo => text().nullable()();
  TextColumn get kplcMeterNo => text().nullable()();
  TextColumn get supplyPhase => text().withDefault(const Constant('single'))();
  IntColumn get occupantCount => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get staticIp => text().nullable()();
  IntColumn get localApiPort => integer().withDefault(const Constant(8443))();
  BoolColumn get allowLanCommands =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get allowCloudCommands =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached `/sites/{id}/rooms`.
class CachedRooms extends Table {
  TextColumn get id => text()();
  TextColumn get siteId => text()();
  TextColumn get name => text()();
  TextColumn get roomType => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached `/sites/{id}/members` (active memberships).
class CachedSiteMembers extends Table {
  IntColumn get id => integer()(); // backend surrogate id
  TextColumn get siteId => text()();
  TextColumn get userId => text()();
  TextColumn get phoneE164 => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get role => text()(); // owner | member | viewer | installer
  TextColumn get grantedBy => text().nullable()();
  DateTimeColumn get grantedAt => dateTime().nullable()();
  DateTimeColumn get revokedAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
