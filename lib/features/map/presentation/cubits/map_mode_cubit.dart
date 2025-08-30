//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/cubits/map_mode_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

enum MapListingMode { nearby, events }

class MapModeState extends Equatable {
  final MapListingMode mode;
  const MapModeState(this.mode);

  @override
  List<Object?> get props => [mode];
}

class MapModeCubit extends Cubit<MapModeState> {
  MapModeCubit() : super(const MapModeState(MapListingMode.nearby));

  void setNearby() => emit(const MapModeState(MapListingMode.nearby));
  void setEvents() => emit(const MapModeState(MapListingMode.events));
}
