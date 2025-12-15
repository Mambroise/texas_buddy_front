//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/dtos/nearby_dtos.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

class NearbyItemDto {
  final String id;

  /// "activity" | "event"
  final String type;
  final String name;
  final double latitude;
  final double longitude;

  /// has_promotion
  final bool hasPromotion;

  /// is_advertisement
  final bool isAdvertisement;

  /// average_rating (nullable)
  final double? averageRating;

  /// Catégories normalisées (clé d’icône "fa-xxx" si dispo, sinon nom)
  final List<String> categories;

  /// image (nullable)
  final String? imageUrl;

  /// distance (km) (nullable)
  final double? distanceKm;

  /// primary category for markers (icon key if provided, else name)
  final String? primaryCategory;

  /// ✅ for events only
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  /// ✅ Durée en minutes (backend peut renvoyer int OU "HH:MM:SS")
  final int? durationMinutes;

  const NearbyItemDto({
    required this.id,
    required this.type,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.hasPromotion,
    required this.isAdvertisement,
    this.averageRating,
    this.categories = const <String>[],
    this.imageUrl,
    this.distanceKm,
    this.primaryCategory,
    this.startDateTime,
    this.endDateTime,
    this.durationMinutes,
  });

  /// Factory tolérante aux alias de clés (latitude/lat, longitude/lng/lon, etc.)
  factory NearbyItemDto.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) {
      if (v == null) throw const FormatException('null cannot be parsed to double');
      if (v is num) return v.toDouble();
      final s = v.toString().trim();
      if (s.isEmpty) throw const FormatException('empty string');
      return double.parse(s);
    }

    bool asBool(dynamic v) {
      if (v is bool) return v;
      if (v == null) return false;
      final s = v.toString().trim().toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }

    String asString(dynamic v) => (v ?? '').toString();

    DateTime? asDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.parse(s); // ISO8601 (Django) supporté (avec ou sans timezone)
    }

    int? asIntNullable(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    /// ✅ Parse une durée qui peut être:
    /// - int/num (minutes)
    /// - "120" (minutes)
    /// - "HH:MM:SS" ou "MM:SS" (Django duration)
    int? asDurationMinutes(dynamic v) {
      if (v == null) return null;

      // nombre direct
      if (v is int) return v;
      if (v is num) return v.toInt();

      final s = v.toString().trim();
      if (s.isEmpty) return null;

      // "120"
      final direct = int.tryParse(s);
      if (direct != null) return direct;

      // "HH:MM:SS" ou "MM:SS"
      final parts = s.split(':').map((e) => e.trim()).toList();
      if (parts.length == 3) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final sec = int.tryParse(parts[2]);
        if (h == null || m == null || sec == null) return null;
        return (h * 60) + m + (sec >= 30 ? 1 : 0); // arrondi au min
      }
      if (parts.length == 2) {
        final m = int.tryParse(parts[0]);
        final sec = int.tryParse(parts[1]);
        if (m == null || sec == null) return null;
        return m + (sec >= 30 ? 1 : 0);
      }

      return null;
    }

    final latRaw = json['latitude'] ?? json['lat'];
    final lonRaw = json['longitude'] ?? json['lng'] ?? json['lon'];

    // --------- NORMALISATION DES CATÉGORIES ---------
    // Accepte 'category' OU 'categories' en entrée
    final rawCats = (json['category'] as List?) ??
        (json['categories'] as List?) ??
        const <dynamic>[];

    // On préfère la clé d’icône (fa-xxx). Fallback sur name.
    // Déduplication en conservant l'ordre.
    final catKeys = <String>[];
    final seen = <String>{};

    void addCat(String? v) {
      final key = v?.trim();
      if (key == null || key.isEmpty) return;
      if (seen.add(key)) catKeys.add(key);
    }

    for (final e in rawCats) {
      if (e is Map) {
        final icon = e['icon']?.toString();
        final name = e['name']?.toString();
        if (icon != null && icon.trim().isNotEmpty) {
          addCat(icon);
        } else {
          addCat(name);
        }
      } else if (e != null) {
        // parfois l’API renvoie directement une chaîne
        addCat(e.toString());
      }
    }
    // -----------------------------------------------

    // 🔑 Clé d’icône pour le marqueur : icon FA prioritaire, sinon name, sinon null
    String? primaryCategoryKey(Map<String, dynamic>? pc) {
      if (pc == null) return null;
      final icon = pc['icon']?.toString().trim();
      if (icon != null && icon.isNotEmpty) return icon; // ex: "fa-utensils"
      final name = pc['name']?.toString().trim();
      return (name != null && name.isNotEmpty) ? name : null;
    }

    final Map<String, dynamic>? pc = json['primary_category'] is Map
        ? (json['primary_category'] as Map).cast<String, dynamic>()
        : null;
    final primaryCatKey = primaryCategoryKey(pc);

    // ✅ alias pour dates d’événements
    final startRaw =
        json['start_datetime'] ?? json['startDateTime'] ?? json['start'] ?? json['start_date'];
    final endRaw =
        json['end_datetime'] ?? json['endDateTime'] ?? json['end'] ?? json['end_date'];

    // ✅ alias pour durée (minutes OU "HH:MM:SS")
    final durationRaw = json['duration_minutes'] ??
        json['duration'] ?? // ex: "02:00:00"
        json['estimated_duration_minutes'] ??
        json['estimatedDurationMinutes'];

    return NearbyItemDto(
      id: asString(json['id'] ?? json['uuid'] ?? json['pk']),
      type: asString(json['type'] ?? 'activity'),
      name: asString(json['name']),
      latitude: asDouble(latRaw),
      longitude: asDouble(lonRaw),
      hasPromotion: asBool(json['has_promotion']),
      isAdvertisement: asBool(json['is_advertisement']),
      averageRating: json['average_rating'] == null ? null : asDouble(json['average_rating']),
      categories: catKeys, // ✅ clés normalisées (fa-xxx si dispo)
      imageUrl: json['image']?.toString(),
      distanceKm: json['distance'] == null ? null : asDouble(json['distance']),
      primaryCategory: primaryCatKey, // ✅ clé normalisée aussi
      startDateTime: asDate(startRaw),
      endDateTime: asDate(endRaw),

      // ✅ NEW (supporte "HH:MM:SS")
      durationMinutes: asDurationMinutes(durationRaw) ?? asIntNullable(durationRaw),
    );
  }

  NearbyItem toDomain() {
    final kind = type.toLowerCase() == 'event' ? NearbyKind.event : NearbyKind.activity;

    return NearbyItem(
      id: id,
      kind: kind,
      name: name,
      latitude: latitude,
      longitude: longitude,
      hasPromotion: hasPromotion,
      isAdvertisement: isAdvertisement,
      averageRating: averageRating,
      // on prend la valeur normalisée par fromJson (fa-xxx prioritaire, sinon name)
      primaryCategory: (primaryCategory != null && primaryCategory!.isNotEmpty)
          ? primaryCategory
          : null,
      categories: categories, // ✅ on passe les clés normalisées
      imageUrl: imageUrl,
      distanceKm: distanceKm,
      startDateTime: startDateTime,
      endDateTime: endDateTime,

      // ✅ NEW
      durationMinutes: durationMinutes,
    );
  }

  /// Utilitaire : extrait une liste depuis une réponse paginée DRF ({ results: [...] }).
  static List<NearbyItemDto> listFromPagedJson(Map<String, dynamic> json) {
    final results = (json['results'] as List?) ?? const <dynamic>[];
    return results
        .whereType<Map<String, dynamic>>()
        .map(NearbyItemDto.fromJson)
        .toList();
  }

  /// Utilitaire : extrait une liste directe (si le backend renvoie déjà une liste à la racine).
  static List<NearbyItemDto> listFromJsonArray(List<dynamic> arr) {
    return arr.whereType<Map<String, dynamic>>().map(NearbyItemDto.fromJson).toList();
  }
}
