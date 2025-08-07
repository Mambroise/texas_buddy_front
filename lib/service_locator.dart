//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :lib/service_locator.dart
// Author : Morice
//-------------------------------------------------------------------------



import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'data/datasources/remote/auth/auth_remote_datasource.dart';
import 'data/datasources/local/token_storage.dart';
import 'data/repositories/auth/auth_repositories_impl.dart';
import 'domain/repositories/auth/auth_repository.dart';

import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/verify_registration_usecase.dart';
import 'domain/usecases/auth/request_password_reset_usecase.dart';
import 'domain/usecases/auth/resend_registration_number_usecase.dart';
import 'domain/usecases/auth/verify_reset_pwd_2fa_usecase.dart';
import 'domain/usecases/auth/set_password_usecase.dart';
import 'domain/usecases/auth/verify_registration_2fa_usecase.dart';
import 'domain/usecases/auth/set_password_registration_usecase.dart';

import 'presentation/blocs/auth/login_bloc.dart';
import 'presentation/blocs/auth/signup_bloc.dart';
import 'presentation/blocs/auth/forgot_password_bloc.dart';
import 'presentation/blocs/auth/resend_registration_bloc.dart';


final getIt = GetIt.instance;

void setupLocator(Dio dio) {
  // 1) Dio fourni en paramètre
  getIt.registerLazySingleton<Dio>(() => dio);

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
  getIt.registerFactory<VerifyRegistrationUseCase>(
        () => VerifyRegistrationUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<RequestPasswordResetUseCase>(
        () => RequestPasswordResetUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ResendRegistrationNumberUseCase>(
        () => ResendRegistrationNumberUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<VerifyResetPwd2FACodeUseCase>(
        () => VerifyResetPwd2FACodeUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SetPasswordUseCase>(
        () => SetPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() =>
      VerifyRegistration2FACodeUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<SetPasswordForRegistrationUseCase>(
        () => SetPasswordForRegistrationUseCase(getIt<AuthRepository>()),
  );

  // 6) Blocs
  getIt.registerFactory<LoginBloc>(
        () => LoginBloc(getIt<LoginUseCase>()),
  );
  getIt.registerFactory(() => SignupBloc(
    getIt<VerifyRegistrationUseCase>(),
    getIt<VerifyRegistration2FACodeUseCase>(),
    getIt<SetPasswordForRegistrationUseCase>()//
  ));

  getIt.registerFactory<ResendRegistrationBloc>(
        () => ResendRegistrationBloc(getIt<ResendRegistrationNumberUseCase>()),
  );
  getIt.registerFactory<ForgotPasswordBloc>(
        () => ForgotPasswordBloc(
      getIt<RequestPasswordResetUseCase>(),
      getIt<VerifyResetPwd2FACodeUseCase>(),
      getIt<SetPasswordUseCase>(),
    ),
  );
}
