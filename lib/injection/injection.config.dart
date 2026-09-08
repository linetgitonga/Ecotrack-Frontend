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

import '../core/auth/session_manager.dart' as _i538;
import '../core/auth/step_up_controller.dart' as _i4;
import '../core/auth/token_store.dart' as _i906;
import '../core/connectivity/connection_manager.dart' as _i959;
import '../core/connectivity/mdns_discovery.dart' as _i480;
import '../core/network/dio_factory.dart' as _i110;
import '../core/network/network_wiring.dart' as _i172;
import '../core/sync/outbox_processor.dart' as _i451;
import '../core/sync/realtime_client.dart' as _i906;
import '../core/sync/sync_engine.dart' as _i869;
import '../data/local/database/app_database.dart' as _i130;
import '../data/local/database/daos/site_dao.dart' as _i675;
import '../data/local/database/daos/sync_dao.dart' as _i463;
import '../data/local/preferences/app_preferences.dart' as _i372;
import '../data/local/preferences/secure_storage.dart' as _i666;
import '../data/remote/api/api_client.dart' as _i101;
import '../data/remote/api/audit_api.dart' as _i897;
import '../data/remote/api/auth_api.dart' as _i765;
import '../data/remote/api/me_api.dart' as _i286;
import '../data/remote/api/sites_api.dart' as _i334;
import '../data/remote/api/tierb_api.dart' as _i258;
import '../data/repositories/auth_repository.dart' as _i578;
import '../data/repositories/site_repository.dart' as _i667;
import '../features/account/presentation/bloc/members_cubit.dart' as _i869;
import '../features/account/presentation/bloc/sessions_cubit.dart' as _i582;
import '../features/account/presentation/bloc/site_bloc.dart' as _i25;
import '../features/auth/presentation/bloc/auth_bloc.dart' as _i59;
import '../features/connectivity/presentation/bloc/connectivity_bloc.dart'
    as _i612;
import '../features/devices/presentation/bloc/device_list_cubit.dart' as _i737;
import '../features/home/presentation/bloc/home_dashboard_bloc.dart' as _i305;
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
    gh.lazySingleton<_i675.SiteDao>(
      () => _i675.SiteDao(gh<_i130.AppDatabase>()),
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
    gh.lazySingleton<_i612.ConnectivityBloc>(
      () => _i612.ConnectivityBloc(gh<_i959.ConnectionManager>()),
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
    gh.lazySingleton<_i897.AuditApi>(
      () => _i897.AuditApi(gh<_i101.ApiClient>(instanceName: 'cloud')),
    );
    gh.lazySingleton<_i765.AuthApi>(
      () => _i765.AuthApi(gh<_i101.ApiClient>(instanceName: 'cloud')),
    );
    gh.lazySingleton<_i286.MeApi>(
      () => _i286.MeApi(gh<_i101.ApiClient>(instanceName: 'cloud')),
    );
    gh.lazySingleton<_i334.SitesApi>(
      () => _i334.SitesApi(gh<_i101.ApiClient>(instanceName: 'cloud')),
    );
    gh.lazySingleton<_i258.TierBApi>(
      () => _i258.TierBApi(gh<_i101.ApiClient>(instanceName: 'cloud')),
    );
    gh.lazySingleton<_i4.StepUpController>(
      () => _i4.StepUpController(gh<_i765.AuthApi>()),
    );
    gh.factory<_i737.DeviceListCubit>(
      () => _i737.DeviceListCubit(gh<_i258.TierBApi>()),
    );
    gh.factory<_i305.HomeDashboardBloc>(
      () => _i305.HomeDashboardBloc(gh<_i258.TierBApi>()),
    );
    gh.lazySingleton<_i667.SiteRepository>(
      () => _i667.SiteRepository(
        gh<_i334.SitesApi>(),
        gh<_i675.SiteDao>(),
        gh<_i463.SyncDao>(),
      ),
    );
    gh.lazySingleton<_i25.SiteBloc>(
      () =>
          _i25.SiteBloc(gh<_i667.SiteRepository>(), gh<_i372.AppPreferences>()),
    );
    gh.factory<_i869.MembersCubit>(
      () => _i869.MembersCubit(
        gh<_i667.SiteRepository>(),
        gh<_i4.StepUpController>(),
      ),
    );
    gh.lazySingleton<_i538.SessionManager>(
      () => _i538.SessionManager(
        gh<_i765.AuthApi>(),
        gh<_i906.TokenStore>(),
        gh<_i172.NetworkWiring>(),
      ),
    );
    gh.lazySingleton<_i578.AuthRepository>(
      () => _i578.AuthRepository(
        gh<_i765.AuthApi>(),
        gh<_i286.MeApi>(),
        gh<_i906.TokenStore>(),
        gh<_i130.AppDatabase>(),
        gh<_i372.AppPreferences>(),
      ),
    );
    gh.factory<_i582.SessionsCubit>(
      () => _i582.SessionsCubit(gh<_i578.AuthRepository>()),
    );
    gh.lazySingleton<_i59.AuthBloc>(
      () =>
          _i59.AuthBloc(gh<_i578.AuthRepository>(), gh<_i538.SessionManager>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$NetworkModule extends _i110.NetworkModule {}
