// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_dao.dart';

// ignore_for_file: type=lint
mixin _$DeviceDaoMixin on DatabaseAccessor<AppDatabase> {
  $CachedDevicesTable get cachedDevices => attachedDatabase.cachedDevices;
  $CachedRollupsTable get cachedRollups => attachedDatabase.cachedRollups;
  DeviceDaoManager get managers => DeviceDaoManager(this);
}

class DeviceDaoManager {
  final _$DeviceDaoMixin _db;
  DeviceDaoManager(this._db);
  $$CachedDevicesTableTableManager get cachedDevices =>
      $$CachedDevicesTableTableManager(_db.attachedDatabase, _db.cachedDevices);
  $$CachedRollupsTableTableManager get cachedRollups =>
      $$CachedRollupsTableTableManager(_db.attachedDatabase, _db.cachedRollups);
}
