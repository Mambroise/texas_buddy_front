//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : feztures/planning/data/dtos/activity_or_event_dto.dart
// Author : Morice
//---------------------------------------------------------------------------

class ActivityOrEventDto {
  final int id;
  final String name;
  final String type;      // "activity" | "event"
  final String? placeId;  // peut être null côté event
  final double latitude;
  final double longitude;
  final String? primaryIcon;
  final List<String> otherIcons;

  ActivityOrEventDto({
    required this.id,
    required this.name,
    required this.type,
    this.placeId,
    required this.latitude,
    required this.longitude,
    this.primaryIcon,
    this.otherIcons = const [],
  });

  factory ActivityOrEventDto.fromJson(Map<String, dynamic> j) {
    String? primaryIcon;
    final List<String> icons = [];

    // primary_category.icon || primaryCategory.icon
    final pc = (j['primary_category'] ?? j['primaryCategory']);
    if (pc is Map) {
      final v = pc['icon'];
      if (v is String && v.trim().isNotEmpty) {
        primaryIcon = v.trim();
      }
    }

    // categories[] || category[]
    final rawCats = j['categories'] ?? j['category'];
    if (rawCats is List) {
      for (final c in rawCats) {
        if (c is Map) {
          final v = c['icon'];
          if (v is String && v.trim().isNotEmpty) {
            icons.add(v.trim());
          }
        }
      }
    }

    // fallback: si pas de primaryIcon, prends la 1ère icône de la liste
    primaryIcon ??= icons.isNotEmpty ? icons.first : null;

    // otherIcons = toutes les icônes sauf la primaire
    final otherIcons = (primaryIcon == null)
        ? List<String>.from(icons)
        : icons.where((i) => i != primaryIcon).toList();

    return ActivityOrEventDto(
      id: j['id'] as int,
      name: j['name'] as String,
      type: (j['type'] as String?) ?? 'activity',
      placeId: j['place_id'] as String?,
      latitude: (j['latitude'] as num).toDouble(),
      longitude: (j['longitude'] as num).toDouble(),
      primaryIcon: primaryIcon,
      otherIcons: otherIcons,
    );
  }

}
