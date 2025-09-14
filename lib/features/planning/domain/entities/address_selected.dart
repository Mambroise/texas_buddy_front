//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/entities/address_selected.dart
// Author : Morice
//---------------------------------------------------------------------------


class AddressSelected {
  final int addressCacheId;
  final String placeId;
  final String? formattedAddress;
  final double? lat;
  final double? lng;
  final String? city;
  final String? stateCode;
  final String? countryCode;

  AddressSelected({
    required this.addressCacheId,
    required this.placeId,
    this.formattedAddress,
    this.lat,
    this.lng,
    this.city,
    this.stateCode,
    this.countryCode,
  });
}
