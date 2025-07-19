//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/models/trip_model.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:flutter/foundation.dart';

/// Trip Model
class TripModel {
  final int? id;
  final int userId;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final int adults;
  final int children;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TripModel({
    this.id,
    required this.userId,
    required this.title,
    this.startDate,
    this.endDate,
    this.adults = 1,
    this.children = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date'] as String) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      adults: map['adults'] as int,
      children: map['children'] as int,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'adults': adults,
      'children': children,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}