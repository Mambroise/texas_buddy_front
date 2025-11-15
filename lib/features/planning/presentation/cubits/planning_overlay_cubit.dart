//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/cubits/planning_overlay_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart'; // TimeOfDay helpers

import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_day.dart';
import '../../domain/entities/trip_step.dart';

// ✅ injecté par constructeur
import '../../domain/usecases/trips/create_trip_step.dart';
import '../../domain/usecases/travel/compute_travel.dart'; // travel estimate
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
      final newDays = t.days
          .map((d) => d.id == newDay.id ? newDay : d)
          .toList();
      // ignore: avoid_dynamic_calls
      final Trip newTrip = (t as dynamic).copyWith(days: newDays) as Trip;
      emit(state.copyWith(selectedTrip: newTrip, selectedDay: newDay));
    } catch (_) {
      _emitWithUpdatedDayOnly(newDay);
    }
  }

  /// Recalcule le trajet vers [stepToUpdate] (depuis [previousStep] ou l'hôtel)
  /// puis persiste les nouveaux champs travel_* via UpdateTripStep.
  ///
  /// Retourne un nouveau TripDay avec ce step mis à jour.
  Future<TripDay> _recomputeAndPersistTravelForStep({
    required TripDay day,
    required TripStep? previousStep,
    required TripStep stepToUpdate,
    String mode = 'driving',
    String? lang,
  }) async {
    if (stepToUpdate.id == null) {
      d('[OverlayCubit] _recomputeAndPersistTravelForStep: step sans id, skip');
      return day;
    }

    double? originLat;
    double? originLng;

    // Origine = coords du step précédent s'il en a, sinon coords du TripDay (hôtel)
    if (previousStep != null &&
        (previousStep.target.latitude != 0 || previousStep.target.longitude != 0)) {
      originLat = previousStep.target.latitude;
      originLng = previousStep.target.longitude;
    } else {
      // ⚠️ ne considère pas (0,0) comme valable
      if (day.latitude != null && day.longitude != null &&
          (day.latitude != 0 || day.longitude != 0)) {
        originLat = day.latitude;
        originLng = day.longitude;
      }
    }

    final destLat = stepToUpdate.target.latitude;
    final destLng = stepToUpdate.target.longitude;

    int minutes = 0;
    int meters = 0;

    if (originLat != null &&
        originLng != null &&
        destLat != null &&
        destLng != null) {
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

    // 1) Step mis à jour LOCAL (même si le backend refuse derrière)
    TripStep updatedLocal = stepToUpdate;
    try {
      updatedLocal = (stepToUpdate as dynamic).copyWith(
        travelDurationMinutes: minutes,
        travelDistanceMeters: meters,
      ) as TripStep;
    } catch (_) {
      d('[OverlayCubit] _recomputeAndPersistTravelForStep: copyWith indisponible, '
          'le step restera tel quel en mémoire.');
    }

    // 2) Met à jour la journée en mémoire -> l’UI verra au moins ça
    TripDay localDay = _replaceStepInDay(day, updatedLocal);

    // 3) PATCH backend si possible, mais sans casser l’UI si ça plante
    try {
      final TripStep updatedRemote = await updateTripStep.execute(
        id: stepToUpdate.id!,
        travelDurationMinutes: minutes,
        travelDistanceMeters: meters,
      );

      final TripDay remoteDay = _replaceStepInDay(localDay, updatedRemote);
      d('[OverlayCubit] _recomputeAndPersistTravelForStep: backend OK, '
          'travel=${updatedRemote.travelDurationMinutes}');
      return remoteDay;
    } catch (e, st) {
      d('[OverlayCubit] _recomputeAndPersistTravelForStep updateTripStep ERROR: $e\n$st');
      // On garde quand même la version locale pour l’UI
      return localDay;
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

  // ---- Time helpers -------------------------------------------------------

  int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _fromMin(int m) =>
      TimeOfDay(hour: (m ~/ 60).clamp(0, 23), minute: (m % 60).clamp(0, 59));

  int _stepStartMin(TripStep s) => s.startHour * 60 + s.startMinute;

  int _stepEndMin(TripStep s) {
    if (s.endHour != null && s.endMinute != null) {
      return (s.endHour! * 60) + s.endMinute!;
    }
    final dur = (s.estimatedDurationMinutes is int &&
        s.estimatedDurationMinutes > 0)
        ? s.estimatedDurationMinutes
        : 60;
    return _stepStartMin(s) + dur;
  }

  // ---- Estimation trajet pour hover --------------------------------------

  /// Calcule (minutes, meters) et une éventuelle contrainte [minStart] = end(prev)+travel
  /// pour un hover au temps [intendedStart] vers [destLat,destLng].
  Future<
      ({int minutes, int meters, TimeOfDay? minStart})?> estimateTravelForHover(
      {
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
      final sorted = [...day.steps]
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

    // Origine = prev coords sinon hôtel
    double? oLat, oLng;
    if (prev != null &&
        (prev.target.latitude != 0 || prev.target.longitude != 0)) {
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
      // premier step du jour
      minStart = null;
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

  void hide() =>
      emit(const PlanningOverlayState(visible: false, expanded: false));

  // ---- Data wiring --------------------------------------------------------

  void applyRefreshedTrip(Trip newTrip) {
    final int? curDayId = state.selectedDay?.id;

    TripDay? newSelectedDay;
    if (curDayId != null) {
      newSelectedDay =
          newTrip.days.firstWhereOrNull((d) => d.id == curDayId);
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
      d('[OverlayCubit] selectDay: found id=${found.id} addr="${found
          .address}" '
          'steps=${found.steps.length}');
    } catch (_) {
      d('[OverlayCubit] selectDay: found id=${found.id} addr="${found
          .address}" steps=<no field>');
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
    int? travelDurationMinutes,
    int? travelDistanceMeters,
  }) async {
    try {
      // 1) Domaine → API (création du step)
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

      // 2) Récupérer le TripDay concerné
      TripDay? day = state.selectedDay;
      if (day == null || day.id != tripDayId) {
        day = _dayById(tripDayId);
      }
      if (day == null) {
        d('[OverlayCubit] createTripStepFromTarget: TripDay $tripDayId not found in state');
        return;
      }

      // 3) Ajouter le step dans la liste
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

      // 4) Recalculer le trajet du step suivant, s'il existe
      TripDay finalDay = baseDay;
      try {
        final sorted = [...baseSteps]
          ..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));

        final idx = sorted.indexWhere((s) => s.id == saved.id);
        if (idx != -1 && idx + 1 < sorted.length) {
          final TripStep origin = saved;           // le nouveau step
          final TripStep nextStep = sorted[idx + 1]; // le suivant

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


  // ---- Suppression d'un step ----------------------------------------------

  /// Supprime un step par son [stepId] dans le TripDay courant.
  /// Retourne true si tout s'est bien passé (step trouvé & supprimé côté backend + state).
  Future<bool> deleteStep(int stepId) async {
    try {
      TripDay? day = state.selectedDay;

      // si la selectedDay ne contient pas ce step, on cherche dans le trip courant
      if (day == null || !day.steps.any((s) => s.id == stepId)) {
        final t = state.selectedTrip;
        if (t == null) return false;
        day = t.days.firstWhereOrNull(
              (d) => d.steps.any((s) => s.id == stepId),
        );
        if (day == null) return false;
      }

      TripDay workDay = day;

      // 1) Identifier prev / deleted / next pour recalculer le trajet du "next"
      TripStep? prev;
      TripStep? deleted;
      TripStep? next;

      try {
        final sorted = [...workDay.steps]
          ..sort((a, b) => _stepStartMin(a).compareTo(_stepStartMin(b)));

        final idx = sorted.indexWhere((s) => s.id == stepId);
        if (idx != -1) {
          deleted = sorted[idx];
          if (idx > 0) prev = sorted[idx - 1];
          if (idx + 1 < sorted.length) next = sorted[idx + 1];
        }
      } catch (e, st) {
        d('[OverlayCubit] deleteStep sorting ERROR: $e\n$st');
      }

      // 2) Si on a un "next", on recalcule son trajet depuis prev (ou hôtel)
      if (next != null) {
        workDay = await _recomputeAndPersistTravelForStep(
          day: workDay,
          previousStep: prev,
          stepToUpdate: next,
        );
      }

      // 3) Supprime le step dans la journée (côté state)
      final List<TripStep> updatedSteps =
      workDay.steps.where((s) => s.id != stepId).toList();

      if (updatedSteps.length == workDay.steps.length) {
        // rien n'a été supprimé localement → step introuvable
        return false;
      }

      // 4) Backend delete
      await deleteTripStep.execute(stepId: stepId);

      // 5) Mise à jour de la journée dans le state
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


  Future<void> updateStepFromEditor(/* params ou TripStep */) async {
    // 1) appel usecase -> TripStep updated
    // 2) remplacer le step dans le TripDay courant
    // 3) _emitWithUpdatedTripIfPossible(newDay)
  }

}
