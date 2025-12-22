//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/data/dtos/interest_category_dto.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:texas_buddy/features/user/domain/entities/interest_category.dart';

class InterestCategoryDto {
  final int id;
  final String name;
  final String? icon;
  final String? description;

  const InterestCategoryDto({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });

  factory InterestCategoryDto.fromJson(Map<String, dynamic> json) {
    int i(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    String s(dynamic v) => (v ?? '').toString();
    String? sn(dynamic v) {
      final x = v?.toString();
      return (x == null || x.isEmpty) ? null : x;
    }

    return InterestCategoryDto(
      id: i(json['id']),
      name: s(json['name']),
      icon: sn(json['icon']),
      description: sn(json['description']),
    );
  }

  InterestCategory toDomain() => InterestCategory(
    id: id,
    name: name,
    icon: icon,
    description: description,
  );
}
