import 'package:texas_buddy/features/user/domain/repositories/user_interests_repository.dart';
import 'package:texas_buddy/features/user/data/datasources/remote/user_interests_remote_data_source.dart';

class UserInterestsRepositoryImpl implements UserInterestsRepository {
  final UserInterestsRemoteDataSource remote;
  const UserInterestsRepositoryImpl(this.remote);

  @override
  Future<void> saveInterests({required List<int> categoryIds}) {
    return remote.updateUserInterests(categoryIds: categoryIds);
  }
}
