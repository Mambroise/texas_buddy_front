//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/data/datasources/remote/auth/interests_remote_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:dio/dio.dart';
import '../../dtos/interest_category_dto.dart';

abstract class InterestsRemoteDataSource {
  Future<List<InterestCategoryDto>> fetchCategories();
}

class InterestsRemoteDataSourceImpl implements InterestsRemoteDataSource {
  final Dio dio;
  const InterestsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<InterestCategoryDto>> fetchCategories() async {
    // ⚠️ adapte si ton prefix API diffère
    final res = await dio.get('/activities/categories/');

    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(InterestCategoryDto.fromJson)
          .toList();
    }

    // fallback si DRF pagination un jour: {results: [...]}
    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(InterestCategoryDto.fromJson)
          .toList();
    }

    return const [];
  }
}
