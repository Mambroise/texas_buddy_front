//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/models/advertisement_model.dart
// Author : Morice
//-------------------------------------------------------------------------


/// Advertisement Model
class AdvertisementModel {
  final int? id;
  final String? ioReferenceNumber;
  final int contractId;
  final String campaignType;
  final String format;
  final String? title;
  final String? adCreativeContentText;
  final String? imageUrl;
  final String? videoUrl;
  final String linkUrl;
  final String? pushMessage;
  final DateTime startDate;
  final DateTime endDate;
  final int? relatedActivityId;
  final int? relatedEventId;


  AdvertisementModel({
    this.id,
    this.ioReferenceNumber,
    required this.contractId,
    required this.campaignType,
    required this.format,
    this.title,
    this.adCreativeContentText,
    this.imageUrl,
    this.videoUrl,
    required this.linkUrl,
    this.pushMessage,
    required this.startDate,
    required this.endDate,
    this.relatedActivityId,
    this.relatedEventId,
  });

  factory AdvertisementModel.fromMap(Map<String, dynamic> map) {
    return AdvertisementModel(
      id: map['id'] as int?,
      ioReferenceNumber: map['io_reference_number'] as String?,
      contractId: map['contract_id'] as int,
      campaignType: map['campaign_type'] as String,
      format: map['format'] as String,
      title: map['title'] as String?,
      adCreativeContentText: map['ad_creative_content_text'] as String?,
      imageUrl: map['image_url'] as String?,
      videoUrl: map['video_url'] as String?,
      linkUrl: map['link_url'] as String,
      pushMessage: map['push_message'] as String?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      relatedActivityId: map['related_activity_id'] as int?,
      relatedEventId: map['related_event_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'io_reference_number': ioReferenceNumber,
      'contract_id': contractId,
      'campaign_type': campaignType,
      'format': format,
      'title': title,
      'ad_creative_content_text': adCreativeContentText,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'link_url': linkUrl,
      'push_message': pushMessage,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'related_activity_id': relatedActivityId,
      'related_event_id': relatedEventId,
    };
  }
}