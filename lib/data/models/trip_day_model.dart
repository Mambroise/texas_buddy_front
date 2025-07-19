//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/models/trip_day_model.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:flutter/foundation.dart';


/// TripDay Model
class TripDayModel {
  final int? id;
  final int tripId;
  final DateTime date;
  final int? addressCacheId;

  TripDayModel({
    this.id,
    required this.tripId,
    required this.date,
    this.addressCacheId,
  });

  factory TripDayModel.fromMap(Map<String, dynamic> map) {
    return TripDayModel(
      id: map['id'] as int?,
      tripId: map['trip_id'] as int,
      date: DateTime.parse(map['date'] as String),
      addressCacheId: map['address_cache_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'date': date.toIso8601String(),
      'address_cache_id': addressCacheId,
    };
  }
}
