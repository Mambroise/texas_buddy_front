//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/cubits/planning_overlay_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_day.dart';
import '../../domain/entities/trip_step.dart';

import '../../domain/usecases/trips/create_trip_step.dart';
import '../../domain/usecases/travel/compute_travel.dart';
import '../../domain/usecases/trips/delete_trip_step.dart';
import '../../domain/usecases/trips/update_trip_step.dart';

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
        selectedDay: clearDay ? null : (selectedDay ?? this.selectedDay),
      );

  @override
  List<Object?> get props => [visible, expanded, selectedTrip, selectedDay];
}

class PlanningOverlayCubit extends Cubit<PlanningOverlayState> {
  // ✅ Usecases injectés
  final CreateTripStep createTripStep;
  final ComputeTravel computeTravel;
  final DeleteTripStep deleteTripStep;
  final UpdateTripStep updateTripStep;

  PlanningOverlayCubit({
    required this.createTripStep,
    required this.computeTravel,
    required this.deleteTripStep,
    required this.updateTripStep,
  }) : super(PlanningOverlayState.initial());

  bool kPlanningDebug = true;

  void d(String msg) {
    if (kPlanningDebug) print(msg);
  }

  // ------------------------------------------------------------------------
  // Helpers privés
  // ------------------------------------------------------------------------

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

  TripDay _replaceStepInDay(TripDay day, TripStep updatedStep) {
    final List<TripStep> newSteps = day.steps.map((s) {
      if (s.id == updatedStep.id) return updatedStep;
      return s;
    }).toList();

    try {
      // ignore: avoid_dynamic_calls
      return (day as dynamic).copyWith(steps: newSteps) as TripDay;
    } catch (_) {
      return TripDay(
        id: day.id,
        date: day.date,
        address: day.address,
        latitude: day.latitude,
        longitude: day.longitude,
        steps: newSteps,
      );
    }
  }

  // ------------------------------------------------------------------------
  // Time helpers
  // ------------------------------------------------------------------------

  int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _fromMin(int m) =>
      TimeOfDay(hour: (m ~/ 60).clamp(0, 23), minute: (m % 60).clamp(0, 59));

  int _stepStartMin(TripStep s) => s.startHour * 60 + s.startMinute;

  int _stepDurationMin(TripStep s) {
    if (s.estimatedDurationMinutes > 0) return s.estimatedDurationMinutes;
    final end = _stepEndMin(s);
    final start = _stepStartMin(s);
    final d = end - start;
    return d > 0 ? d : 60;
  }

  int _stepEndMin(TripStep s) {
    if (s.endHour != null && s.endMinute != null) {
      return (s.endHour! * 60) + s.endMinute!;
    }
    final dur = (s.estimatedDurationMinutes > 0) ? s.estimatedDurationMinutes : 60;
    return _stepStartMin(s) + dur;
  }

  // ------------------------------------------------------------------------
  // Travel compute & persist (déjà existant, sécurisée)
  // ------------------------------------------------------------------------

  /// Recalcule le trajet vers [stepToUpdate] (depuis [previousStep] ou l'hôtel)
  /// puis persiste travel_* via UpdateTripStep.
  Future<TripDay> _recomputeAndPersistTravelForStep({
    required TripDay day,
    required TripStep? previousStep,
    required TripStep stepToUpdate,
    String mode = 'driving',
    String? lang,
  }) async {
    double? originLat;
    double? originLng;

    // Origine = coords du step précédent si dispo, sinon coords du TripDay (hôtel)
    if (previousStep != null &&
        (previousStep.target.latitude != 0 || previousStep.target.longitude != 0)) {
      originLat = previousStep.target.latitude;
      originLng = previousStep.target.longitude;
    } else {
      if (day.latitude != null &&
          day.longitude != null &&
          (day.latitude != 0 || day.longitude != 0)) {
        originLat = day.latitude;
        originLng = day.longitude;
      }
    }

    final destLat = stepToUpdate.target.latitude;
    final destLng = stepToUpdate.target.longitude;

    int minutes = 0;
    int meters = 0;

    if (originLat != null && originLng != null) {
      try {
        final (m, dist) = await computeTravel(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          mode: mode,
          lang: lang,
        );
        minutes = m;
        meters = dist;
        d('[OverlayCubit] _recomputeAndPersistTravelForStep computeTravel '
            'origin=($originLat,$originLng) dest=($destLat,$destLng) '
            '=> minutes=$minutes meters=$meters');
      } catch (e, st) {
        d('[OverlayCubit] _recomputeAndPersistTravelForStep computeTravel ERROR: $e\n$st');
      }
    } else {
      d('[OverlayCubit] _recomputeAndPersistTravelForStep: coords manquantes, '
          'origin=($originLat,$originLng) dest=($destLat,$destLng) => minutes=0');
    }

    // 1) local update (UI)
    TripStep updatedLocal = stepToUpdate;
    try {
      updatedLocal = (stepToUpdate as dynamic).copyWith(
        travelDurationMinutes: minutes,
        travelDistanceMeters: meters,
      ) as TripStep;
    } catch (_) {
      d('[OverlayCubit] _recomputeAndPersistTravelForStep: copyWith indisponible.');
    }

    TripDay localDay = _replaceStepInDay(day, updatedLocal);

    // 2) persist backend
    try {
      final TripStep updatedRemote = await updateTripStep.execute(
        id: stepToUpdate.id,
        travelDurationMinutes: minutes,
        travelDistanceMeters: meters,
      );

      final TripDay remoteDay = _replaceStepInDay(localDay, updatedRemote);
      d('[OverlayCubit] _recomputeAndPersistTravelForStep: backend OK, '
          'travel=${updatedRemote.travelDurationMinutes}');
      return remoteDay;
    } catch (e, st) {
      d('[OverlayCubit] _recomputeAndPersistTravelForStep updateTripStep ERROR: $e\n$st');
      return localDay;
    }
  }

  // ------------------------------------------------------------------------
  // Estimation trajet pour hover (CREATE) - inchangé
  // ------------------------------------------------------------------------

  Future<({int minutes, int meters, TimeOfDay? minStart})?> estimateTravelForHover({
    required int tripDayId,
    required TimeOfDay intendedStart,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    String? lang,
  }) async {
    final day = (state.selectedDay?.id == tripDayId) ? state.selectedDay : _dayById(tripDayId);
    if (day == null) return null;

    // prev : dernier step dont end <= intendedStart
    final aim = _toMin(intendedStart);
    TripStep? prev;

    if (day.steps.isNotEmpty) {
      final sorted = [...day.steps]..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));
      for (final s in sorted) {
        final end = _stepEndMin(s);
        if (end <= aim) {
          prev = s;
        } else {
          break;
        }
      }
    }

    double? oLat, oLng;
    if (prev != null && (prev.target.latitude != 0 || prev.target.longitude != 0)) {
      oLat = prev.target.latitude;
      oLng = prev.target.longitude;
    } else {
      oLat = day.latitude;
      oLng = day.longitude;
    }

    if (oLat == null || oLng == null) {
      return (minutes: 0, meters: 0, minStart: null);
    }

    final (minu, metr) = await computeTravel(
      originLat: oLat,
      originLng: oLng,
      destLat: destLat,
      destLng: destLng,
      mode: mode,
      lang: lang,
    );

    TimeOfDay? minStart;
    if (prev != null) {
      final prevEnd = _stepEndMin(prev);
      minStart = _fromMin((prevEnd + minu).clamp(0, 23 * 60 + 59));
    }

    return (minutes: minu, meters: metr, minStart: minStart);
  }

  // ------------------------------------------------------------------------
  // ✅ Estimation trajet pour MOVE step (DRAG) - NOUVEAU
  // ------------------------------------------------------------------------

  /// Comme estimateTravelForHover, mais en ignorant le step déplacé (movingStepId)
  /// pour déterminer le "prev". Utilisé par le ghost de drag.
  Future<({int minutes, int meters, TimeOfDay? minStart})?> estimateTravelForStepMove({
    required int tripDayId,
    required int? movingStepId,
    required TimeOfDay intendedStart,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    String? lang,
  }) async {
    final day = (state.selectedDay?.id == tripDayId) ? state.selectedDay : _dayById(tripDayId);
    if (day == null) return null;

    final aim = _toMin(intendedStart);
    TripStep? prev;

    if (day.steps.isNotEmpty) {
      final sorted = [...day.steps]
        ..removeWhere((s) => movingStepId != null && s.id == movingStepId)
        ..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));

      for (final s in sorted) {
        final end = _stepEndMin(s);
        if (end <= aim) {
          prev = s;
        } else {
          break;
        }
      }
    }

    double? oLat, oLng;
    if (prev != null && (prev.target.latitude != 0 || prev.target.longitude != 0)) {
      oLat = prev.target.latitude;
      oLng = prev.target.longitude;
    } else {
      oLat = day.latitude;
      oLng = day.longitude;
    }

    if (oLat == null || oLng == null) {
      return (minutes: 0, meters: 0, minStart: null);
    }

    final (minu, metr) = await computeTravel(
      originLat: oLat,
      originLng: oLng,
      destLat: destLat,
      destLng: destLng,
      mode: mode,
      lang: lang,
    );

    TimeOfDay? minStart;
    if (prev != null) {
      final prevEnd = _stepEndMin(prev);
      minStart = _fromMin((prevEnd + minu).clamp(0, 23 * 60 + 59));
    } else {
      minStart = null; // 1er step => pas de contrainte minStart
    }

    return (minutes: minu, meters: metr, minStart: minStart);
  }

  // ------------------------------------------------------------------------
  // UI controls
  // ------------------------------------------------------------------------

  void toggleOverlay() => emit(state.copyWith(visible: !state.visible));

  void toggleExpanded() {
    if (!state.visible) return;
    emit(state.copyWith(expanded: !state.expanded));
  }

  void expand() => emit(state.copyWith(visible: true, expanded: true));
  void collapse() => emit(state.copyWith(expanded: false));
  void showExpanded() => emit(state.copyWith(visible: true, expanded: true));

  void hide() => emit(const PlanningOverlayState(visible: false, expanded: false));

  // ------------------------------------------------------------------------
  // Data wiring
  // ------------------------------------------------------------------------

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

  void clearTrip() {
    emit(state.copyWith(clearTrip: true, clearDay: true));
  }

  void selectDay(DateTime date) {
    d('[OverlayCubit] selectDay requested: $date');
    final t = state.selectedTrip;
    if (t == null) {
      d('[OverlayCubit] selectDay: NO selectedTrip');
      return;
    }

    TripDay? found;
    for (final dday in t.days) {
      if (dday.date.year == date.year &&
          dday.date.month == date.month &&
          dday.date.day == date.day) {
        found = dday;
        break;
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

  // ------------------------------------------------------------------------
  // Création de step (drop depuis Nearby) - inchangé (avec recalc next)
  // ------------------------------------------------------------------------

  Future<void> createTripStepFromTarget({
    required int tripId,
    required int tripDayId,
    required int startHour,
    required int startMinute,
    required int estimatedDurationMinutes,
    required String targetType,
    required int targetId,
    required String targetName,
    String? primaryIcon,
    List<String> otherIcons = const [],
    String? placeId,
    double? latitude,
    double? longitude,
    int? travelDurationMinutes,
    int? travelDistanceMeters,
  }) async {
    try {
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
        travelDurationMinutes: travelDurationMinutes,
        travelDistanceMeters: travelDistanceMeters,
      );

      TripDay? day = state.selectedDay;
      if (day == null || day.id != tripDayId) {
        day = _dayById(tripDayId);
      }
      if (day == null) {
        d('[OverlayCubit] createTripStepFromTarget: TripDay $tripDayId not found in state');
        return;
      }

      final List<TripStep> baseSteps = [...day.steps, saved];

      TripDay baseDay;
      try {
        // ignore: avoid_dynamic_calls
        baseDay = (day as dynamic).copyWith(steps: baseSteps) as TripDay;
      } catch (_) {
        baseDay = TripDay(
          id: day.id,
          date: day.date,
          address: day.address,
          latitude: day.latitude,
          longitude: day.longitude,
          steps: baseSteps,
        );
      }

      TripDay finalDay = baseDay;
      try {
        final sorted = [...baseSteps]..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));
        final idx = sorted.indexWhere((s) => s.id == saved.id);
        if (idx != -1 && idx + 1 < sorted.length) {
          final TripStep origin = saved;
          final TripStep nextStep = sorted[idx + 1];
          finalDay = await _recomputeAndPersistTravelForStep(
            day: baseDay,
            previousStep: origin,
            stepToUpdate: nextStep,
          );
        }
      } catch (e, st) {
        d('[OverlayCubit] createTripStepFromTarget recalc-next ERROR: $e\n$st');
      }

      _emitWithUpdatedTripIfPossible(finalDay);
      d('[OverlayCubit] step created ✅ (tripDayId=$tripDayId, steps=${finalDay.steps.length})');
    } catch (e, st) {
      d('[OverlayCubit] createTripStepFromTarget ERROR: $e\n$st');
    }
  }

  // ------------------------------------------------------------------------
  // Suppression d'un step - inchangé (avec recalc next)
  // ------------------------------------------------------------------------

  Future<bool> deleteStep(int stepId) async {
    try {
      TripDay? day = state.selectedDay;

      if (day == null || !day.steps.any((s) => s.id == stepId)) {
        final t = state.selectedTrip;
        if (t == null) return false;
        day = t.days.firstWhereOrNull((d) => d.steps.any((s) => s.id == stepId));
        if (day == null) return false;
      }

      TripDay workDay = day;

      TripStep? prev;
      TripStep? next;

      try {
        final sorted = [...workDay.steps]..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));
        final idx = sorted.indexWhere((s) => s.id == stepId);
        if (idx != -1) {
          if (idx > 0) prev = sorted[idx - 1];
          if (idx + 1 < sorted.length) next = sorted[idx + 1];
        }
      } catch (e, st) {
        d('[OverlayCubit] deleteStep sorting ERROR: $e\n$st');
      }

      if (next != null) {
        workDay = await _recomputeAndPersistTravelForStep(
          day: workDay,
          previousStep: prev,
          stepToUpdate: next,
        );
      }

      final List<TripStep> updatedSteps = workDay.steps.where((s) => s.id != stepId).toList();
      if (updatedSteps.length == workDay.steps.length) return false;

      await deleteTripStep.execute(stepId: stepId);

      TripDay newDay;
      try {
        // ignore: avoid_dynamic_calls
        newDay = (workDay as dynamic).copyWith(steps: updatedSteps) as TripDay;
      } catch (_) {
        newDay = TripDay(
          id: workDay.id,
          date: workDay.date,
          address: workDay.address,
          latitude: workDay.latitude,
          longitude: workDay.longitude,
          steps: updatedSteps,
        );
      }

      _emitWithUpdatedTripIfPossible(newDay);
      d('[OverlayCubit] deleteStep($stepId) OK, remaining=${updatedSteps.length}');
      return true;
    } catch (e, st) {
      d('[OverlayCubit] deleteStep ERROR: $e\n$st');
      return false;
    }
  }

  // ------------------------------------------------------------------------
  // Update duration depuis editor (inchangé, tel que fourni)
  // ------------------------------------------------------------------------

  Future<bool> updateStepFromEditor({
    required int stepId,
    required int newDurationMinutes,
  }) async {
    try {
      if (newDurationMinutes <= 0) return false;

      TripDay? day = state.selectedDay;

      if (day == null || !day.steps.any((s) => s.id == stepId)) {
        final t = state.selectedTrip;
        if (t == null) return false;
        day = t.days.firstWhereOrNull((d) => d.steps.any((s) => s.id == stepId));
        if (day == null) return false;
      }

      final List<TripStep> sorted = [...day.steps]..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));
      final int idx = sorted.indexWhere((s) => s.id == stepId);
      if (idx == -1) return false;

      final TripStep original = sorted[idx];

      int oldDuration;
      if (original.estimatedDurationMinutes > 0) {
        oldDuration = original.estimatedDurationMinutes;
      } else {
        oldDuration = _stepEndMin(original) - _stepStartMin(original);
        if (oldDuration <= 0) oldDuration = 60;
      }

      final int delta = newDurationMinutes - oldDuration;

      d('[OverlayCubit] updateStepFromEditor stepId=$stepId '
          'oldDur=$oldDuration newDur=$newDurationMinutes delta=$delta');

      final Map<int, TripStep> localUpdatesById = {};

      TripStep editedLocal = original;
      final int startMin = _stepStartMin(original);
      final int newEndMin = startMin + newDurationMinutes;
      final int newEndHour = (newEndMin ~/ 60).clamp(0, 23);
      final int newEndMinute = (newEndMin % 60).clamp(0, 59);

      try {
        editedLocal = (original as dynamic).copyWith(
          estimatedDurationMinutes: newDurationMinutes,
          endHour: newEndHour,
          endMinute: newEndMinute,
        ) as TripStep;
      } catch (_) {}
      localUpdatesById[original.id] = editedLocal;

      if (delta != 0) {
        for (int i = idx + 1; i < sorted.length; i++) {
          final TripStep s = sorted[i];

          final int shiftedStartMin = _stepStartMin(s) + delta;

          int dur;
          if (s.estimatedDurationMinutes > 0) {
            dur = s.estimatedDurationMinutes;
          } else {
            dur = _stepEndMin(s) - _stepStartMin(s);
            if (dur <= 0) dur = 60;
          }

          final int shiftedEndMin = shiftedStartMin + dur;

          final int newStartHourS = (shiftedStartMin ~/ 60).clamp(0, 23);
          final int newStartMinuteS = (shiftedStartMin % 60).clamp(0, 59);
          final int newEndHourS = (shiftedEndMin ~/ 60).clamp(0, 23);
          final int newEndMinuteS = (shiftedEndMin % 60).clamp(0, 59);

          TripStep shifted = s;
          try {
            shifted = (s as dynamic).copyWith(
              startHour: newStartHourS,
              startMinute: newStartMinuteS,
              endHour: newEndHourS,
              endMinute: newEndMinuteS,
            ) as TripStep;
          } catch (_) {}

          localUpdatesById[s.id] = shifted;
        }
      }

      final List<TripStep> newStepsLocal = day.steps.map((s) {
        final sid = s.id;
        if (localUpdatesById.containsKey(sid)) {
          return localUpdatesById[sid]!;
        }
        return s;
      }).toList();

      TripDay localDay;
      try {
        // ignore: avoid_dynamic_calls
        localDay = (day as dynamic).copyWith(steps: newStepsLocal) as TripDay;
      } catch (_) {
        localDay = TripDay(
          id: day.id,
          date: day.date,
          address: day.address,
          latitude: day.latitude,
          longitude: day.longitude,
          steps: newStepsLocal,
        );
      }

      _emitWithUpdatedTripIfPossible(localDay);

      TripDay currentDay = localDay;

      TripStep updatedMain;
      try {
        updatedMain = await updateTripStep.execute(
          id: original.id,
          estimatedDurationMinutes: newDurationMinutes,
        );
        currentDay = _replaceStepInDay(currentDay, updatedMain);
      } catch (e, st) {
        d('[OverlayCubit] updateStepFromEditor main updateTripStep ERROR: $e\n$st');
        return false;
      }

      if (idx + 1 >= sorted.length) {
        _emitWithUpdatedTripIfPossible(currentDay);
        return true;
      }

      final TripStep nextOrig = sorted[idx + 1];

      currentDay = await _recomputeAndPersistTravelForStep(
        day: currentDay,
        previousStep: updatedMain,
        stepToUpdate: nextOrig,
      );

      final TripStep nextInDay = currentDay.steps.firstWhere((s) => s.id == nextOrig.id);

      final int minStartForNext = _stepEndMin(updatedMain) + (nextInDay.travelDurationMinutes);
      final int curNextStart = _stepStartMin(nextInDay);

      if (curNextStart < minStartForNext) {
        final int shift = minStartForNext - curNextStart;

        d('[OverlayCubit] updateStepFromEditor: shift following by +$shift min '
            '(due to travel constraint)');

        for (int i = idx + 1; i < sorted.length; i++) {
          final TripStep s = sorted[i];

          final TripStep cur = currentDay.steps.firstWhere((x) => x.id == s.id);

          final int newStartMin = _stepStartMin(cur) + shift;
          final int newStartHour = (newStartMin ~/ 60).clamp(0, 23);
          final int newStartMinute = (newStartMin % 60).clamp(0, 59);

          try {
            final TripStep updated = await updateTripStep.execute(
              id: cur.id,
              startHour: newStartHour,
              startMinute: newStartMinute,
            );
            currentDay = _replaceStepInDay(currentDay, updated);
          } catch (e, st) {
            d('[OverlayCubit] updateStepFromEditor shift updateTripStep ERROR: $e\n$st');
            return false;
          }
        }
      } else {
        if (delta != 0) {
          for (int i = idx + 1; i < sorted.length; i++) {
            final TripStep s = sorted[i];

            final TripStep? local = localUpdatesById[s.id];
            if (local == null) continue;

            try {
              final TripStep updated = await updateTripStep.execute(
                id: s.id,
                startHour: local.startHour,
                startMinute: local.startMinute,
              );
              currentDay = _replaceStepInDay(currentDay, updated);
            } catch (e, st) {
              d('[OverlayCubit] updateStepFromEditor following(delta) updateTripStep ERROR: $e\n$st');
              return false;
            }
          }
        }
      }

      _emitWithUpdatedTripIfPossible(currentDay);
      return true;
    } catch (e, st) {
      d('[OverlayCubit] updateStepFromEditor FATAL ERROR: $e\n$st');
      return false;
    }
  }

  // ------------------------------------------------------------------------
  // ✅ GROSSE ÉTAPE : MOVE step depuis drag (update startTime + travel + shifts)
  // ------------------------------------------------------------------------

  /// Déplace un step à une nouvelle heure (drag vertical).
  ///
  /// Objectifs :
  /// - UI optimiste immédiat (ordre + start/end).
  /// - Backend :
  ///   1) PATCH startHour/startMinute du step déplacé
  ///   2) Recompute/persist travel du step déplacé (prev -> moved)
  ///   3) Recompute/persist travel du step suivant du moved (moved -> next)
  ///   4) Recompute/persist travel du step qui suit l'ancien prev (oldPrev -> oldNext)
  ///   5) Enforce contraintes minStart : si un step démarre trop tôt, shift et persiste
  ///
  /// Retourne true si tout a été correctement persisté.
  Future<bool> moveStepFromDrag({
    required int stepId,
    required TimeOfDay newStart,
    String mode = 'driving',
    String? lang,
  }) async {
    try {
      TripDay? day = state.selectedDay;

      // trouver day contenant step
      if (day == null || !day.steps.any((s) => s.id == stepId)) {
        final t = state.selectedTrip;
        if (t == null) return false;
        day = t.days.firstWhereOrNull((d) => d.steps.any((s) => s.id == stepId));
        if (day == null) return false;
      }

      // sorted baseline
      final List<TripStep> sortedBefore = [...day.steps]..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));
      final int oldIdx = sortedBefore.indexWhere((s) => s.id == stepId);
      if (oldIdx == -1) return false;

      final TripStep movedOrig = sortedBefore[oldIdx];

      final TripStep? oldPrev = (oldIdx > 0) ? sortedBefore[oldIdx - 1] : null;
      final TripStep? oldNext = (oldIdx + 1 < sortedBefore.length) ? sortedBefore[oldIdx + 1] : null;

      final int movedDur = _stepDurationMin(movedOrig);

      // --------------------------------------------------------------------
      // 0) UI optimiste : applique newStart (start/end) puis resort
      // --------------------------------------------------------------------
      final int ns = _toMin(newStart);
      final int newStartHour = (ns ~/ 60).clamp(0, 23);
      final int newStartMinute = (ns % 60).clamp(0, 59);

      final int newEndMin = ns + movedDur;
      final int newEndHour = (newEndMin ~/ 60).clamp(0, 23);
      final int newEndMinute = (newEndMin % 60).clamp(0, 59);

      TripStep movedLocal = movedOrig;
      try {
        movedLocal = (movedOrig as dynamic).copyWith(
          startHour: newStartHour,
          startMinute: newStartMinute,
          endHour: newEndHour,
          endMinute: newEndMinute,
        ) as TripStep;
      } catch (_) {}

      // remplacer dans day.steps
      TripDay optimisticDay = _replaceStepInDay(day, movedLocal);
      _emitWithUpdatedTripIfPossible(optimisticDay);

      // --------------------------------------------------------------------
      // 1) Backend : PATCH start du moved (obligatoire)
      // --------------------------------------------------------------------
      TripDay currentDay = optimisticDay;

      TripStep movedRemote;
      try {
        movedRemote = await updateTripStep.execute(
          id: stepId,
          startHour: newStartHour,
          startMinute: newStartMinute,
        );
        currentDay = _replaceStepInDay(currentDay, movedRemote);
      } catch (e, st) {
        d('[OverlayCubit] moveStepFromDrag main updateTripStep ERROR: $e\n$st');
        return false;
      }

      // rebuild sortedAfter (avec moved à sa nouvelle position)
      final List<TripStep> sortedAfter = [...currentDay.steps]
        ..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));

      final int newIdx = sortedAfter.indexWhere((s) => s.id == stepId);
      final TripStep movedInDay = sortedAfter[newIdx];

      final TripStep? newPrev = (newIdx > 0) ? sortedAfter[newIdx - 1] : null;
      final TripStep? newNext = (newIdx + 1 < sortedAfter.length) ? sortedAfter[newIdx + 1] : null;

      // --------------------------------------------------------------------
      // 2) Recompute travel pour moved (newPrev -> moved)
      // --------------------------------------------------------------------
      currentDay = await _recomputeAndPersistTravelForStep(
        day: currentDay,
        previousStep: newPrev,
        stepToUpdate: movedInDay,
        mode: mode,
        lang: lang,
      );

      // --------------------------------------------------------------------
      // 3) Recompute travel pour newNext (moved -> newNext)
      // --------------------------------------------------------------------
      if (newNext != null) {
        currentDay = await _recomputeAndPersistTravelForStep(
          day: currentDay,
          previousStep: currentDay.steps.firstWhere((s) => s.id == stepId),
          stepToUpdate: currentDay.steps.firstWhere((s) => s.id == newNext.id),
          mode: mode,
          lang: lang,
        );
      }

      // --------------------------------------------------------------------
      // 4) Recompute travel pour oldNext si le moved a "quitté" son emplacement
      //    => oldPrev -> oldNext (après suppression du moved entre eux)
      // --------------------------------------------------------------------
      if (oldNext != null && oldNext.id != newNext?.id) {
        // oldNext existe encore et n'est pas le newNext (cas typique de déplacement)
        final TripStep? oldPrevStill = (oldPrev != null)
            ? currentDay.steps.firstWhereOrNull((s) => s.id == oldPrev.id)
            : null;

        final TripStep? oldNextStill =
        currentDay.steps.firstWhereOrNull((s) => s.id == oldNext.id);

        if (oldNextStill != null) {
          currentDay = await _recomputeAndPersistTravelForStep(
            day: currentDay,
            previousStep: oldPrevStill,
            stepToUpdate: oldNextStill,
            mode: mode,
            lang: lang,
          );
        }
      }

      // --------------------------------------------------------------------
      // 5) Enforce contraintes : cascade shift si un step démarre trop tôt
      //    Règle : start(step) >= end(prev) + travel(step)
      //    (travel est stocké SUR step)
      // --------------------------------------------------------------------
      // On repart d'une liste triée à jour.
      List<TripStep> enforceSorted = [...currentDay.steps]
        ..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));

      // helper local pour patcher start
      Future<bool> patchStart(TripStep s, int startMin) async {
        final int sh = (startMin ~/ 60).clamp(0, 23);
        final int sm = (startMin % 60).clamp(0, 59);
        try {
          final TripStep updated = await updateTripStep.execute(
            id: s.id,
            startHour: sh,
            startMinute: sm,
          );
          currentDay = _replaceStepInDay(currentDay, updated);
          return true;
        } catch (e, st) {
          d('[OverlayCubit] moveStepFromDrag patchStart ERROR: $e\n$st');
          return false;
        }
      }

      // cascade
      for (int i = 0; i < enforceSorted.length; i++) {
        final TripStep cur = currentDay.steps.firstWhere((x) => x.id == enforceSorted[i].id);

        final TripStep? prev = (i > 0)
            ? currentDay.steps.firstWhere((x) => x.id == enforceSorted[i - 1].id)
            : null;

        final int curStart = _stepStartMin(cur);

        int minStart = 0;
        if (prev != null) {
          final int prevEnd = _stepEndMin(prev);
          final int travel = cur.travelDurationMinutes; // travel *vers cur*
          minStart = prevEnd + travel;
        } else {
          // premier step : pas de contrainte (comme ton hover), sauf si tu veux forcer hôtel+travel,
          // mais on garde le même comportement pour ne pas régresser.
          minStart = curStart;
        }

        if (curStart < minStart) {
          final int shiftTo = minStart;
          final ok = await patchStart(cur, shiftTo);
          if (!ok) return false;

          // après patch, il faut aussi recalculer end local si ton backend ne renvoie pas endHour/endMinute
          // (mais updateTripStep devrait renvoyer le step complet).
          // On re-synchronise la liste triée.
          enforceSorted = [...currentDay.steps]..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));
          // on continue : le shift peut impacter les suivants
        }
      }

      // --------------------------------------------------------------------
      // Etat final
      // --------------------------------------------------------------------
      _emitWithUpdatedTripIfPossible(currentDay);
      return true;
    } catch (e, st) {
      d('[OverlayCubit] moveStepFromDrag FATAL ERROR: $e\n$st');
      return false;
    }
  }
}
