//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/entities/address_suggestion.dart
// Author : Morice
//---------------------------------------------------------------------------


class AddressSuggestion {
  final String placeId;
  final String name;
  final String? formattedAddress;
  final double? lat;
  final double? lng;
  final String? city;
  final String? stateCode;
  final String? countryCode;
  final String? source; // "cache" | "google"
  final int? addressCacheId; // NEW pour items venant du cache

  AddressSuggestion({
    required this.placeId,
    required this.name,
    this.formattedAddress,
    this.lat,
    this.lng,
    this.city,
    this.stateCode,
    this.countryCode,
    this.source,
    this.addressCacheId,
  });
}
