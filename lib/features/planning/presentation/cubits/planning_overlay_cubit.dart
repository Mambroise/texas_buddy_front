//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/cubits/planning_overlay_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart'; // NEW: TimeOfDay helpers

import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_day.dart';
import '../../domain/entities/trip_step.dart';

// ✅ injecté par constructeur
import '../../domain/usecases/trips/create_trip_step.dart';
import '../../domain/usecases/travel/compute_travel.dart'; // NEW

class PlanningOverlayState extends Equatable {
  final bool visible;
  final bool expanded;
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
  // ✅ Usecase fortement typé et non-null
  final CreateTripStep createTripStep;
  final ComputeTravel computeTravel; // NEW

  PlanningOverlayCubit({
    required this.createTripStep,
    required this.computeTravel, // NEW
  }) : super(PlanningOverlayState.initial());

  bool kPlanningDebug = true;
  void d(String msg) { if (kPlanningDebug) print(msg); }

// ---- Helpers privés -----------------------------------------------------

  TripDay? _dayById(int id) {
    final t = state.selectedTrip;
    if (t == null) return null;
    return t.days.firstWhereOrNull((d) => d.id == id);
  }

  void _emitWithUpdatedDayOnly(TripDay newDay) {
    emit(state.copyWith(selectedDay: newDay));
  }

  void _emitWithUpdatedTripIfPossible(TripDay newDay) {
    final t = state.selectedTrip;
    if (t == null) {
      _emitWithUpdatedDayOnly(newDay);
      return;
    }
    try {
      final newDays = t.days.map((d) => d.id == newDay.id ? newDay : d).toList();
// ignore: avoid_dynamic_calls
      final Trip newTrip = (t as dynamic).copyWith(days: newDays) as Trip;
      emit(state.copyWith(selectedTrip: newTrip, selectedDay: newDay));
    } catch (_) {
      _emitWithUpdatedDayOnly(newDay);
    }
  }

  // ---- Time helpers (NEW) -------------------------------------------------
  int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;
  TimeOfDay _fromMin(int m) =>
      TimeOfDay(hour: (m ~/ 60).clamp(0, 23), minute: (m % 60).clamp(0, 59));

  int _stepStartMin(TripStep s) => s.startHour * 60 + s.startMinute;
  int _stepEndMin(TripStep s) {
    if (s.endHour != null && s.endMinute != null) {
      return (s.endHour! * 60) + s.endMinute!;
    }
    final dur = (s.estimatedDurationMinutes is int && s.estimatedDurationMinutes > 0)
        ? s.estimatedDurationMinutes
        : 60;
    return _stepStartMin(s) + dur;
  }

  // ---- Estimation trajet pour hover (NEW) --------------------------------
  /// Calcule (minutes, meters) et une éventuelle contrainte [minStart] = end(prev)+travel
  /// pour un hover au temps [intendedStart] vers [destLat,destLng].
  Future<({int minutes, int meters, TimeOfDay? minStart})?> estimateTravelForHover({
    required int tripDayId,
    required TimeOfDay intendedStart,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    String? lang,
  }) async {
    final day = (state.selectedDay?.id == tripDayId)
        ? state.selectedDay
        : _dayById(tripDayId);
    if (day == null) return null;

    // Step précédent : dernier step dont end <= intendedStart
    final aim = _toMin(intendedStart);
    TripStep? prev;
    if (day.steps.isNotEmpty) {
      final sorted = [...day.steps]..sort((a,b) => _stepStartMin(a).compareTo(_stepStartMin(b)));
      for (final s in sorted) {
        final end = _stepEndMin(s);
        if (end <= aim) prev = s; else break;
      }
    }

    // Origine = prev coords sinon hôtel
    double? oLat, oLng;
    if (prev != null && (prev.target.latitude != 0 || prev.target.longitude != 0)) {
      oLat = prev.target.latitude;
      oLng = prev.target.longitude;
    } else {
      oLat = day.latitude;
      oLng = day.longitude;
    }

    if (oLat == null || oLng == null) {
      // pas d'ancre géolocalisée : pas de contrainte minimum
      return (minutes: 0, meters: 0, minStart: null);
    }

    final (minu, metr) = await computeTravel(
      originLat: oLat, originLng: oLng,
      destLat: destLat, destLng: destLng,
      mode: mode, lang: lang,
    );

    TimeOfDay? minStart;
    if (prev != null) {
      final prevEnd = _stepEndMin(prev);
      minStart = _fromMin((prevEnd + minu).clamp(0, 23*60 + 59));
    } else {
      minStart = null; // premier step du jour
    }

    return (minutes: minu, meters: metr, minStart: minStart);
  }

// ---- UI controls --------------------------------------------------------

  void toggleOverlay() => emit(state.copyWith(visible: !state.visible));

  void toggleExpanded() {
    if (!state.visible) return;
    emit(state.copyWith(expanded: !state.expanded));
  }

  void expand() => emit(state.copyWith(visible: true, expanded: true));
  void collapse() => emit(state.copyWith(expanded: false));
  void showExpanded() => emit(state.copyWith(visible: true, expanded: true));
  void hide() => emit(const PlanningOverlayState(visible: false, expanded: false));

// ---- Data wiring --------------------------------------------------------

  void applyRefreshedTrip(Trip newTrip) {
    final int? curDayId = state.selectedDay?.id;

    TripDay? newSelectedDay;
    if (curDayId != null) {
      newSelectedDay = newTrip.days.firstWhereOrNull((d) => d.id == curDayId);
    }
    newSelectedDay ??= newTrip.days.isNotEmpty ? newTrip.days.first : null;

    emit(state.copyWith(
      selectedTrip: newTrip,
      selectedDay: newSelectedDay,
    ));
  }

  void setTrip(Trip t) {
    d('[OverlayCubit] setTrip(tripId=${t.id}) days=${t.days.length}');
    if (t.days.isNotEmpty) {
      final first = t.days.first;
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
      d('[OverlayCubit] selectDay: found id=${found.id} addr="${found.address}" steps=<no field>');
    }
    emit(state.copyWith(selectedDay: found));
  }

// ---- Création de step (drop depuis Nearby) ------------------------------

  Future<void> createTripStepFromTarget({
    required int tripId,
    required int tripDayId,
    required int startHour,
    required int startMinute,
    required int estimatedDurationMinutes,
    required String targetType, // "activity"|"event"
    required int targetId,
    required String targetName,
    String? primaryIcon,
    List<String> otherIcons = const [],
    String? placeId,
    double? latitude,
    double? longitude,
    int? travelDurationMinutes,   // NEW
    int? travelDistanceMeters,    // NEW
  }) async {
    try {
// 1) Domaine → API
      final TripStep saved = await createTripStep.execute(
        tripId: tripId,
        tripDayId: tripDayId,
        startHour: startHour,
        startMinute: startMinute,
        estimatedDurationMinutes: estimatedDurationMinutes,
        targetType: targetType,
        targetId: targetId,
        targetName: targetName,
        primaryIcon: primaryIcon,
        otherIcons: otherIcons,
        placeId: placeId,
        latitude: latitude,
        longitude: longitude,
        // ⚠️ nécessite l'extension du usecase/datasource (Étape 6)
        travelDurationMinutes: travelDurationMinutes,
        travelDistanceMeters: travelDistanceMeters,
      );

// 2) MAJ du TripDay en mémoire
      TripDay? day = state.selectedDay;
      if (day == null || day.id != tripDayId) {
        day = _dayById(tripDayId);
      }
      if (day == null) {
        d('[OverlayCubit] createTripStepFromTarget: TripDay $tripDayId not found in state');
        return;
      }

      final List<TripStep> updatedSteps = [...day.steps, saved];

      TripDay newDay;
      try {
// ignore: avoid_dynamic_calls
        newDay = (day as dynamic).copyWith(steps: updatedSteps) as TripDay;
      } catch (_) {
        newDay = TripDay(
          id: day.id,
          date: day.date,
          address: day.address,
          latitude: day.latitude,
          longitude: day.longitude,
          steps: updatedSteps,
        );
      }

      _emitWithUpdatedTripIfPossible(newDay);
      d('[OverlayCubit] step created ✅ (tripDayId=$tripDayId, steps=${newDay.steps.length})');
    } catch (e, st) {
      d('[OverlayCubit] createTripStepFromTarget ERROR: $e\n$st');
// (optionnel) émet un état d’erreur si tu en as un
    }
  }
}
