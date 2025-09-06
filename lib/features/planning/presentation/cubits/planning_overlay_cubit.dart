//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/cubits/planning_overlay_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_day.dart';

class PlanningOverlayState extends Equatable {
  final bool visible;      // calque affiché ?
  final bool expanded;     // calque entièrement visible ou peek (20%)
  final Trip? selectedTrip;
  final TripDay? selectedDay;

  const PlanningOverlayState({
    required this.visible,
    required this.expanded,
    this.selectedTrip,
    this.selectedDay,
  });

  factory PlanningOverlayState.initial() =>
      const PlanningOverlayState(visible: false, expanded: false);

  PlanningOverlayState copyWith({
    bool? visible,
    bool? expanded,
    Trip? selectedTrip,
    TripDay? selectedDay,
    bool clearTrip = false,
    bool clearDay = false,
  }) =>
      PlanningOverlayState(
        visible: visible ?? this.visible,
        expanded: expanded ?? this.expanded,
        selectedTrip: clearTrip ? null : (selectedTrip ?? this.selectedTrip),
        selectedDay:  clearDay  ? null : (selectedDay  ?? this.selectedDay),
      );

  @override
  List<Object?> get props => [visible, expanded, selectedTrip, selectedDay];
}

class PlanningOverlayCubit extends Cubit<PlanningOverlayState> {
  PlanningOverlayCubit() : super(PlanningOverlayState.initial());
  bool kPlanningDebug = true;
  void d(String msg) { if (kPlanningDebug) print(msg); }


  // === UI controls ===
  void toggleOverlay() => emit(state.copyWith(visible: !state.visible));
  void toggleExpanded() {
    if (!state.visible) return;
    emit(state.copyWith(expanded: !state.expanded));
  }
  void expand() => emit(state.copyWith(visible: true, expanded: true));
  void collapse() => emit(state.copyWith(expanded: false));
  void showExpanded() => emit(state.copyWith(visible: true, expanded: true));
  void hide() => emit(const PlanningOverlayState(visible: false, expanded: false));

  // === Data wiring ===
  /// Injecte un Trip complet (déjà fetch côté repo), positionne selectedDay sur le premier jour.
  void setTrip(Trip t) {
    // DEBUG
    d('[OverlayCubit] setTrip(tripId=${t.id}) days=${t.days.length}');
    if (t.days.isNotEmpty) {
      final first = t.days.first;
      // ⚠️ si TripDay a bien steps[]
      try {
        d('[OverlayCubit] firstDay id=${first.id} date=${first.date} '
            'addr="${first.address}" steps=${first.steps.length}');
      } catch (_) {
        d('[OverlayCubit] firstDay id=${first.id} date=${first.date} '
            'addr="${first.address}" steps=<no field>');
      }
    }

    final first = t.days.isNotEmpty ? t.days.first : null;
    emit(state.copyWith(selectedTrip: t, selectedDay: first));
  }

  /// Change le jour courant par date (ex: depuis le TripDaysStrip).
  void selectDay(DateTime date) {
    d('[OverlayCubit] selectDay requested: $date');
    final t = state.selectedTrip;
    if (t == null) { d('[OverlayCubit] selectDay: NO selectedTrip'); return; }

    TripDay? found;
    for (final dday in t.days) {
      if (dday.date.year == date.year &&
          dday.date.month == date.month &&
          dday.date.day == date.day) {
        found = dday; break;
      }
    }
    if (found == null) {
      d('[OverlayCubit] selectDay: not found, keep previous');
      return;
    }
    try {
      d('[OverlayCubit] selectDay: found id=${found.id} addr="${found.address}" '
          'steps=${found.steps.length}');
    } catch (_) {
      d('[OverlayCubit] selectDay: found id=${found.id} addr="${found.address}" '
          'steps=<no field>');
    }
    emit(state.copyWith(selectedDay: found));
  }

  /// (stub) Création d'un step côté domaine, puis refresh local
  /// A brancher sur ton usecase/repository (POST step, retour step, update TripDay).
  Future<void> createTripStepFromTarget({
    required DateTime day,
    required int startHour,
    required int startMinute,
    required String targetType, // "activity"|"event"
    required int targetId,
    required String targetName,
    String? placeId,
    double? latitude,
    double? longitude,
  }) async {
    // TODO:
    // 1. call usecase -> create step (trip_day_id, start_time, target info…)
    // 2. re-fetch trip OR update selectedDay.steps locally with returned step
    // 3. emit(state.copyWith(selectedTrip: updatedTrip, selectedDay: updatedDay));
  }
}