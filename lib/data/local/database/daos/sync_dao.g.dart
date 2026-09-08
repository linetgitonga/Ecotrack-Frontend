// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncMetaTable get syncMeta => attachedDatabase.syncMeta;
  $OutboxTable get outbox => attachedDatabase.outbox;
  $CommandDedupTable get commandDedup => attachedDatabase.commandDedup;
  SyncDaoManager get managers => SyncDaoManager(this);
}

class SyncDaoManager {
  final _$SyncDaoMixin _db;
  SyncDaoManager(this._db);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db.attachedDatabase, _db.syncMeta);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db.attachedDatabase, _db.outbox);
  $$CommandDedupTableTableManager get commandDedup =>
      $$CommandDedupTableTableManager(_db.attachedDatabase, _db.commandDedup);
}
