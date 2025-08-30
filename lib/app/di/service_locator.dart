//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : lib/app/di/service_locator.dart
// Author : Morice
//---------------------------------------------------------------------------


// lib/app/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

// Core
import 'package:texas_buddy/core/storage/token_storage.dart';

// Router / Auth state
import 'package:texas_buddy/core/network/auth_interceptor.dart';
import 'package:texas_buddy/app/router/auth_notifier.dart';

// Auth (datasource, repo, usecases, blocs)
import 'package:texas_buddy/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:texas_buddy/features/map/data/datasources/remote/all_events_remote_datasource.dart';
import 'package:texas_buddy/features/map/data/repositories/all_events_repository_impl.dart';
import 'package:texas_buddy/features/auth/data/repositories/auth_repositories_impl.dart';
import 'package:texas_buddy/features/auth/domain/repositories/auth_repository.dart';
import 'package:texas_buddy/features/map/domain/repositories/all_events_repository.dart';
import 'package:texas_buddy/features/user/data/datasources/local/user_local_datasource.dart';
import 'package:texas_buddy/features/user/data/datasources/remote/user_remote_datasource.dart';
import 'package:texas_buddy/features/user/data/repositories/user_repository_impl.dart';
import 'package:texas_buddy/features/user/domain/repositories/user_repository.dart';

// usecases
import 'package:texas_buddy/features/auth/domain/usecases/login_usecase.dart';
import 'package:texas_buddy/features/auth/domain/usecases/verify_registration_usecase.dart';
import 'package:texas_buddy/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:texas_buddy/features/auth/domain/usecases/resend_registration_number_usecase.dart';
import 'package:texas_buddy/features/auth/domain/usecases/verify_reset_pwd_2fa_usecase.dart';
import 'package:texas_buddy/features/auth/domain/usecases/set_password_usecase.dart';
import 'package:texas_buddy/features/auth/domain/usecases/verify_registration_2fa_usecase.dart';
import 'package:texas_buddy/features/auth/domain/usecases/set_password_registration_usecase.dart';
import 'package:texas_buddy/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:texas_buddy/features/auth/domain/usecases/logout_usecase.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_cached_nearby_in_bounds.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_all_events_in_bounds.dart';
import 'package:texas_buddy/features/user/domain/usecases/fetch_and_cache_me_usecase.dart';
import 'package:texas_buddy/features/user/domain/usecases/get_cached_user_usecase.dart';

// caches
import 'package:texas_buddy/features/map/data/cache/nearby_memory_cache.dart';
import 'package:texas_buddy/features/map/data/cache/all_events_cache.dart';

import 'package:texas_buddy/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/signup/signup_bloc.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/password/forgot_password_bloc.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/registration/resend_registration_bloc.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/logout/logout_bloc.dart';
import 'package:texas_buddy/features/map/presentation/blocs/all_events/all_events_bloc.dart';

// Map / Location
import 'package:texas_buddy/features/map/data/datasources/location_datasource.dart';
import 'package:texas_buddy/features/map/data/datasources/remote/nearby_remote_datasource.dart';
import 'package:texas_buddy/features/map/data/repositories/location_repository_impl.dart';
import 'package:texas_buddy/features/map/data/repositories/nearby_repository_impl.dart';
import 'package:texas_buddy/features/map/domain/repositories/location_repository.dart';
import 'package:texas_buddy/features/map/domain/repositories/nearby_repository.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_user_position_stream.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_nearby.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_bloc.dart';
import 'package:texas_buddy/features/map/presentation/blocs/nearby/nearby_bloc.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_nearby_in_bounds.dart';

// cubits
import 'package:texas_buddy/features/user/presentation/cubits/user_overview_cubit.dart';

final getIt = GetIt.instance;

/// Call once at app start.
Future<void> setupLocator(Dio dio) async {
  // Utile en dev pour réassigner des singletons lors des hot reloads
  getIt.allowReassignment = true;

  // ── External / Clients ───────────────────────────────────────────────────
  getIt.registerLazySingleton<Dio>(() => dio);

  // ── Core / Storage ───────────────────────────────────────────────────────
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  // Si demain TokenStorage a besoin d’init async:
  // await getIt.registerSingletonAsync<TokenStorage>(() async => await TokenStorage.create());
  // await getIt.isReady<TokenStorage>();

  // ── DataSources ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDatasource>(
        () => AuthRemoteDatasource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<LocationDataSource>(() => LocationDataSourceImpl());
  getIt.registerLazySingleton<NearbyRemoteDataSource>(
        () => NearbyRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AllEventsRemoteDataSource>(() => AllEventsRemoteDataSourceImpl(dio));
  getIt.registerLazySingleton<AllEventsRepository>(() => AllEventsRepositoryImpl(remote: getIt(), cache: getIt()));
  getIt.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(getIt())); // Dio dans getIt
  getIt.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSourceImpl());

  // ── Repositories ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(getIt<AuthRemoteDatasource>(), getIt<TokenStorage>()),
  );
  getIt.registerLazySingleton<LocationRepository>(
        () => LocationRepositoryImpl(getIt<LocationDataSource>()),
  );
  getIt.registerLazySingleton<NearbyRepository>(
        () => NearbyRepositoryImpl(
      getIt<NearbyRemoteDataSource>(),
      getIt<NearbyMemoryCache>(),
    ),
  );
  getIt.registerLazySingleton<UserRepository>(
          () => UserRepositoryImpl(remote: getIt(), local: getIt()));

  // ── UseCases ─────────────────────────────────────────────────────────────
  getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<VerifyRegistrationUseCase>(() => VerifyRegistrationUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<RequestPasswordResetUseCase>(() => RequestPasswordResetUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<ResendRegistrationNumberUseCase>(() => ResendRegistrationNumberUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<VerifyResetPwd2FACodeUseCase>(() => VerifyResetPwd2FACodeUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<SetPasswordUseCase>(() => SetPasswordUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<VerifyRegistration2FACodeUseCase>(() => VerifyRegistration2FACodeUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<SetPasswordForRegistrationUseCase>(() => SetPasswordForRegistrationUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<CheckSessionUseCase>(() => CheckSessionUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GetUserPositionStream>(() => GetUserPositionStream(getIt<LocationRepository>()));
  getIt.registerFactory<LogoutUseCase>(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<GetNearby>(() => GetNearby(getIt<NearbyRepository>()));
  getIt.registerFactory<GetNearbyInBounds>(() => GetNearbyInBounds(getIt<NearbyRepository>()));
  getIt.registerFactory(() => GetCachedNearbyInBounds(getIt<NearbyRepository>()));
  getIt.registerFactory(() => GetAllEventsInBounds(getIt()));
  getIt.registerLazySingleton(() => FetchAndCacheMeUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCachedUserUseCase(getIt()));

  // ── App State (router) ───────────────────────────────────────────────────
  // Important: avant les blocs qui en dépendent
  getIt.registerLazySingleton<AuthNotifier>(() => AuthNotifier(getIt<CheckSessionUseCase>()));
  // Tu peux faire l’init ici si tu préfères centraliser :
  // await getIt<AuthNotifier>().init();
  // 👉 Interceptor
  getIt.registerLazySingleton<AuthInterceptor>(() =>
      AuthInterceptor(getIt<TokenStorage>(), getIt<Dio>(), auth: getIt<AuthNotifier>()));

  // Attacher l'interceptor au client (éventuellement après d’autres interceptors comme logs)
  getIt<Dio>().interceptors.add(getIt<AuthInterceptor>());

  // ── Blocs (Presentation) ─────────────────────────────────────────────────
  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt<LoginUseCase>(), getIt<AuthNotifier>(), getIt<FetchAndCacheMeUseCase>()));
  getIt.registerFactory<SignupBloc>(() => SignupBloc(
    getIt<VerifyRegistrationUseCase>(),
    getIt<VerifyRegistration2FACodeUseCase>(),
    getIt<SetPasswordForRegistrationUseCase>(),
  ));
  getIt.registerFactory<ResendRegistrationBloc>(() => ResendRegistrationBloc(getIt<ResendRegistrationNumberUseCase>()));
  getIt.registerFactory<ForgotPasswordBloc>(() => ForgotPasswordBloc(
    getIt<RequestPasswordResetUseCase>(),
    getIt<VerifyResetPwd2FACodeUseCase>(),
    getIt<SetPasswordUseCase>(),
  ));
  getIt.registerFactory<LogoutBloc>(() => LogoutBloc(getIt<LogoutUseCase>(), getIt<AuthNotifier>()));
  getIt.registerFactory<LocationBloc>(() => LocationBloc(getIt<GetUserPositionStream>()));
  getIt.registerFactory(() => NearbyBloc(
    getNearby: getIt<GetNearby>(),
    getNearbyInBounds: getIt<GetNearbyInBounds>(),
    getCachedInBounds: getIt<GetCachedNearbyInBounds>(),
  ));
  getIt.registerFactory<AllEventsBloc>(() => AllEventsBloc(
    getAllEventsInBounds: getIt<GetAllEventsInBounds>(),
  ));

  // cache
  getIt.registerLazySingleton(() => NearbyMemoryCache(ttl: const Duration(minutes: 2)));
  getIt.registerLazySingleton<AllEventsCache>(() => AllEventsCache());

  // cubits
  getIt.registerFactory(() => UserOverviewCubit(getCached: getIt(), refreshRemote: getIt()));
}
