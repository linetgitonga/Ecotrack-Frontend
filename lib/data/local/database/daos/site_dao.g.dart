// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_dao.dart';

// ignore_for_file: type=lint
mixin _$SiteDaoMixin on DatabaseAccessor<AppDatabase> {
  $CachedSitesTable get cachedSites => attachedDatabase.cachedSites;
  $CachedRoomsTable get cachedRooms => attachedDatabase.cachedRooms;
  $CachedSiteMembersTable get cachedSiteMembers =>
      attachedDatabase.cachedSiteMembers;
  SiteDaoManager get managers => SiteDaoManager(this);
}

class SiteDaoManager {
  final _$SiteDaoMixin _db;
  SiteDaoManager(this._db);
  $$CachedSitesTableTableManager get cachedSites =>
      $$CachedSitesTableTableManager(_db.attachedDatabase, _db.cachedSites);
  $$CachedRoomsTableTableManager get cachedRooms =>
      $$CachedRoomsTableTableManager(_db.attachedDatabase, _db.cachedRooms);
  $$CachedSiteMembersTableTableManager get cachedSiteMembers =>
      $$CachedSiteMembersTableTableManager(
        _db.attachedDatabase,
        _db.cachedSiteMembers,
      );
}
