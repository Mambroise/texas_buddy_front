//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/location/location_event.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

class LocationStarted extends LocationEvent {}
class LocationRecenter extends LocationEvent {}