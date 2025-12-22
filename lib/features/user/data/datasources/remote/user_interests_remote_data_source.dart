//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/data/datasources/remote/user_interests_remote_data_source.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:dio/dio.dart';

abstract class UserInterestsRemoteDataSource {
  Future<void> updateUserInterests({required List<int> categoryIds});
}

class UserInterestsRemoteDataSourceImpl implements UserInterestsRemoteDataSource {
  final Dio dio;
  const UserInterestsRemoteDataSourceImpl(this.dio);

  @override
  Future<void> updateUserInterests({required List<int> categoryIds}) async {
    await dio.patch(
      // ✅ endpoint Django: path('me/interests/', UpdateUserInterestsView...)
      // ⚠️ adapte seulement si ton baseUrl inclut déjà "/api/users" ou "/api"
      '/users/me/interests/',
      data: {'interests': categoryIds},
    );
  }
}
