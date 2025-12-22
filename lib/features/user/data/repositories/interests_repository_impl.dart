//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/data/repositories/interests_repository_impl.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/user/domain/entities/interest_category.dart';
import 'package:texas_buddy/features/user/domain/repositories/interests_repository.dart';
import '../datasources/remote/interests_remote_data_source.dart';

class InterestsRepositoryImpl implements InterestsRepository {
  final InterestsRemoteDataSource remote;
  const InterestsRepositoryImpl(this.remote);

  @override
  Future<List<InterestCategory>> fetchAllCategories() async {
    final dtos = await remote.fetchCategories();
    final list = dtos.map((e) => e.toDomain()).toList();

    // petit tri UX
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }
}
