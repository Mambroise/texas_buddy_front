//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/cubits/trips_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------



import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/trip.dart';
import '../../domain/usecases/create_trip.dart';
import '../blocs/trips/trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  final CreateTrip createTripUsecase;
  TripsCubit({required this.createTripUsecase}) : super(const TripsState());

  Future<void> create({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required int adults,
    required int children,
  }) async {
    emit(state.copyWith(createStatus: TripCreateStatus.submitting, error: null));
    try {
      final trip = await createTripUsecase(
        TripCreate(
          title: title,
          startDate: startDate,
          endDate: endDate,
          adults: adults,
          children: children,
        ),
      );
      final updated = List<Trip>.from(state.trips)..insert(0, trip);
      emit(state.copyWith(trips: updated, createStatus: TripCreateStatus.success));
    } catch (e) {
      emit(state.copyWith(createStatus: TripCreateStatus.failure, error: e.toString()));
    } finally {
      // repasse à idle pour futures créations
      emit(state.copyWith(createStatus: TripCreateStatus.idle));
    }
  }
}
