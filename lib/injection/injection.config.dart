// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:uuid/uuid.dart' as _i706;

import '../core/auth/token_store.dart' as _i906;
import '../core/connectivity/connection_manager.dart' as _i959;
import '../core/connectivity/mdns_discovery.dart' as _i480;
import '../core/network/dio_factory.dart' as _i110;
import '../core/network/network_wiring.dart' as _i172;
import '../core/sync/outbox_processor.dart' as _i451;
import '../core/sync/realtime_client.dart' as _i906;
import '../core/sync/sync_engine.dart' as _i869;
import '../data/local/database/app_database.dart' as _i130;
import '../data/local/database/daos/sync_dao.dart' as _i463;
import '../data/local/preferences/app_preferences.dart' as _i372;
import '../data/local/preferences/secure_storage.dart' as _i666;
import '../data/remote/api/api_client.dart' as _i101;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i480.MdnsDiscovery>(() => _i480.MdnsDiscovery());
    gh.lazySingleton<_i172.NetworkWiring>(() => _i172.NetworkWiring());
    gh.lazySingleton<_i906.RealtimeClient>(() => _i906.RealtimeClient());
    gh.lazySingleton<_i130.AppDatabase>(() => _i130.AppDatabase());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i706.Uuid>(() => registerModule.uuid);
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.lanDio(),
      instanceName: 'lan',
    );
    gh.lazySingleton<_i666.SecureStorage>(
      () => _i666.SecureStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i101.ApiClient>(
      () => networkModule.lanApiClient(gh<_i361.Dio>(instanceName: 'lan')),
      instanceName: 'lan',
    );
    gh.lazySingleton<_i372.AppPreferences>(
      () => _i372.AppPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i906.TokenStore>(
      () => _i906.TokenStore(gh<_i666.SecureStorage>()),
    );
    gh.lazySingleton<_i959.ConnectionManager>(
      () => _i959.ConnectionManager(
        gh<_i372.AppPreferences>(),
        gh<_i666.SecureStorage>(),
        gh<_i172.NetworkWiring>(),
        gh<_i361.Dio>(instanceName: 'lan'),
        gh<_i480.MdnsDiscovery>(),
        gh<_i895.Connectivity>(),
      ),
    );
    gh.lazySingleton<_i463.SyncDao>(
      () => _i463.SyncDao(gh<_i130.AppDatabase>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.cloudDio(
        gh<_i906.TokenStore>(),
        gh<_i172.NetworkWiring>(),
      ),
      instanceName: 'cloud',
    );
    gh.lazySingleton<_i451.OutboxProcessor>(
      () => _i451.OutboxProcessor(gh<_i130.AppDatabase>(), gh<_i463.SyncDao>()),
    );
    gh.lazySingleton<_i869.SyncEngine>(
      () => _i869.SyncEngine(
        gh<_i451.OutboxProcessor>(),
        gh<_i959.ConnectionManager>(),
        gh<_i895.Connectivity>(),
      ),
    );
    gh.lazySingleton<_i101.ApiClient>(
      () => networkModule.cloudApiClient(gh<_i361.Dio>(instanceName: 'cloud')),
      instanceName: 'cloud',
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$NetworkModule extends _i110.NetworkModule {}
