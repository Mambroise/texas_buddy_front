//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/usecases/get_user_position_stream.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:texas_buddy/features/map/domain/entities/user_position.dart';
import 'package:texas_buddy/features/map/domain/repositories/location_repository.dart';

class GetUserPositionStream {
  final LocationRepository repository;
  GetUserPositionStream(this.repository);

  Stream<UserPosition> call() => repository.getPositionStream();
}