//---------------------------------------------------------------------------
// File   : features/planning/domain/entities/step_target.dart
// Author : Morice
//---------------------------------------------------------------------------

class StepTarget {
  final int id;
  final String name;
  final String type;     // "activity" | "event"
  final String? placeId;
  final double latitude;
  final double longitude;

  const StepTarget({
    required this.id,
    required this.name,
    required this.type,
    this.placeId,
    required this.latitude,
    required this.longitude,
  });
}
