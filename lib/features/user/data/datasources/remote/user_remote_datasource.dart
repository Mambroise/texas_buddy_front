//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/data/datasources/remote/auth/auth_remote_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:dio/dio.dart';
import 'package:texas_buddy/features/user/data/dtos/user_profile_dto.dart';

abstract class UserRemoteDataSource {
  Future<UserProfileDto> getMe();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;
  UserRemoteDataSourceImpl(this.dio);

  @override
  Future<UserProfileDto> getMe() async {
    final res = await dio.get('/users/users/me/');
    return UserProfileDto.fromJson(res.data as Map<String, dynamic>);
  }
}
