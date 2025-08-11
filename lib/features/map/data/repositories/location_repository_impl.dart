//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/repositories/location_repository_impl.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:texas_buddy/features/map/domain/entities/user_position.dart';
import 'package:texas_buddy/features/map/domain/repositories/location_repository.dart';
import 'package:texas_buddy/features/map/data/datasources/location_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource datasource;
  LocationRepositoryImpl(this.datasource);

  @override
  Stream<UserPosition> getPositionStream() => datasource.positionStream();

  @override
  Future<UserPosition?> getLastKnownPosition() => datasource.getLastKnown();
}