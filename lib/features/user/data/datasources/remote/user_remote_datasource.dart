//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/data/datasources/remote/user_remote_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:dio/dio.dart';
import 'package:texas_buddy/features/user/data/dtos/user_profile_dto.dart';

abstract class UserRemoteDataSource {
  Future<UserProfileDto> getMe();

  Future<UserProfileDto> patchMe({
    String? email,
    String? address,
    String? phone,
    String? country,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;
  UserRemoteDataSourceImpl(this.dio);

  @override
  Future<UserProfileDto> getMe() async {
    final res = await dio.get('/users/users/me/');
    return UserProfileDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<UserProfileDto> patchMe({
    String? email,
    String? address,
    String? phone,
    String? country,
  }) async {
    final body = <String, dynamic>{};

    // backend fields: email, address, phone, country
    if (email != null) body['email'] = email;
    if (address != null) body['address'] = address;
    if (phone != null) body['phone'] = phone;
    if (country != null) body['country'] = country;

    final res = await dio.patch('/users/users/me/', data: body);
    return UserProfileDto.fromJson(res.data as Map<String, dynamic>);
  }
}
