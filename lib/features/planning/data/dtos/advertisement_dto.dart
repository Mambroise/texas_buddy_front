//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/dtos/category_dto.dart
// Author : Morice
//-------------------------------------------------------------------------



/// DTO for Advertisement returned in the nearby list
class AdvertisementDto {
  final int id;
  final String ioReferenceNumber;
  final int contractId;
  final String campaignType;
  final String format;
  final String? title;
  final String linkUrl;
  final DateTime startDate;
  final DateTime endDate;
  // … ajoute les autres champs si nécessaire

  AdvertisementDto({
    required this.id,
    required this.ioReferenceNumber,
    required this.contractId,
    required this.campaignType,
    required this.format,
    this.title,
    required this.linkUrl,
    required this.startDate,
    required this.endDate,
  });

  factory AdvertisementDto.fromJson(Map<String, dynamic> json) {
    return AdvertisementDto(
      id: json['id'] as int,
      ioReferenceNumber: json['io_reference_number'] as String,
      contractId: json['contract_id'] as int,
      campaignType: json['campaign_type'] as String,
      format: json['format'] as String,
      title: json['title'] as String?,
      linkUrl: json['link_url'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  /// Converts this [AdvertisementDto] to a JSON map
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'io_reference_number': ioReferenceNumber,
      'contract_id': contractId,
      'campaign_type': campaignType,
      'format': format,
      'title': title,
      'link_url': linkUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
