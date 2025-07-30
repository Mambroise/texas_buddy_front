//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :lib/service_locator.dart
// Author : Morice
//-------------------------------------------------------------------------



import 'dart:ui'; // pour PlatformDispatcher
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'data/datasources/remote/core/dio_client.dart';
import 'data/datasources/remote/auth/auth_remote_datasource.dart';
import 'data/datasources/local/token_storage.dart';

import 'data/repositories/auth/auth_repositories_impl.dart';
import 'domain/repositories/auth/auth_repository.dart';

import 'domain/usecases/auth/login_usecase.dart';
// (Lorsque tu créeras d’autres use cases, importe‐les ici, par ex.
//  verify_registration_usecase.dart, set_password_usecase.dart, etc.)

import 'presentation/blocs/auth/login_bloc.dart';
// (idem pour d’autres blocs : signup_bloc.dart, reset_password_bloc.dart, …)

final getIt = GetIt.instance;

void setupLocator() {
  // 1) Dio HTTP client (avec Accept-Language)
  getIt.registerLazySingleton<Dio>(() {
    final locale = PlatformDispatcher.instance.locale.toLanguageTag();
    return createDioClient(locale: locale);
  });

  // 2) Remote DataSources
  getIt.registerLazySingleton<AuthRemoteDatasource>(
        () => AuthRemoteDatasource(getIt<Dio>()),
  );

  // 3) Local storage (secure token storage)
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  // 4) Repositories
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt<AuthRemoteDatasource>(),
      getIt<TokenStorage>(),
    ),
  );

  // 5) UseCases
  getIt.registerFactory<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepository>()),
  );
  // → plus tard, tu ajouteras :
  // getIt.registerFactory<VerifyRegistrationUseCase>(…);
  // getIt.registerFactory<SetPasswordUseCase>(…);
  // etc.

  // 6) Blocs / Cubits
  getIt.registerFactory<LoginBloc>(
        () => LoginBloc(getIt<LoginUseCase>()),
  );
  // → et plus tard :
  // getIt.registerFactory<SignupBloc>(…);
  // getIt.registerFactory<ResetPasswordBloc>(…);
  // etc.
}
