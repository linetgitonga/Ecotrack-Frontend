// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../data/local/database/app_database.dart' as _i130;
import '../data/local/database/daos/sync_dao.dart' as _i463;
import '../data/local/preferences/app_preferences.dart' as _i372;
import '../data/local/preferences/secure_storage.dart' as _i666;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i130.AppDatabase>(() => _i130.AppDatabase());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i666.SecureStorage>(
      () => _i666.SecureStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i372.AppPreferences>(
      () => _i372.AppPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i463.SyncDao>(
      () => _i463.SyncDao(gh<_i130.AppDatabase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
