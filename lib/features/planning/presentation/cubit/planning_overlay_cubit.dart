//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/cubit/planning_overlay_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class PlanningOverlayState extends Equatable {
  final bool visible;   // calque affiché ?
  final bool expanded;  // calque entièrement visible ou en "peek" (20%)

  const PlanningOverlayState({
    required this.visible,
    required this.expanded,
  });

  factory PlanningOverlayState.initial() =>
      const PlanningOverlayState(visible: false, expanded: false);

  PlanningOverlayState copyWith({bool? visible, bool? expanded}) =>
      PlanningOverlayState(
        visible: visible ?? this.visible,
        expanded: expanded ?? this.expanded,
      );

  @override
  List<Object?> get props => [visible, expanded];
}

class PlanningOverlayCubit extends Cubit<PlanningOverlayState> {
  PlanningOverlayCubit() : super(PlanningOverlayState.initial());

  /// Toggle demandé depuis la nav bar
  void toggleOverlay() => emit(state.copyWith(visible: !state.visible));

  /// Tap sur la fenêtre timeline -> étendre/réduire
  void toggleExpanded() {
    if (!state.visible) return; // ignore si masqué
    emit(state.copyWith(expanded: !state.expanded));
  }
  void expand() => emit(state.copyWith(visible: true, expanded: true));
  void collapse() => emit(state.copyWith(expanded: false));


  void showExpanded() => emit(state.copyWith(visible: true, expanded: true));
  void hide() => emit(const PlanningOverlayState(visible: false, expanded: false));
}
