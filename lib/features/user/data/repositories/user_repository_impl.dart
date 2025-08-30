import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';
import 'package:texas_buddy/features/user/domain/repositories/user_repository.dart';
import 'package:texas_buddy/features/user/data/datasources/local/user_local_datasource.dart';
import 'package:texas_buddy/features/user/data/datasources/remote/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  final UserLocalDataSource local;

  UserRepositoryImpl({required this.remote, required this.local});

  @override
  Future<UserProfile> fetchMeAndCache() async {
    final dto = await remote.getMe();
    final user = dto.toDomain();
    await local.upsert(user);
    return user;
  }

  @override
  Future<UserProfile?> getCachedUser() => local.getUser();

  @override
  Future<void> upsertLocal(UserProfile user) => local.upsert(user);

  @override
  Future<void> clearLocal() => local.clear();
}
