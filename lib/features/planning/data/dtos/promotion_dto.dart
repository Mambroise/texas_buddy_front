//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :features/planning/data/dtos/promotion_dto.dart
// Author : Morice
//-------------------------------------------------------------------------


/// Data Transfer Object for promotion data
class PromotionDto {
  final int id;
  final String title;
  final String description;
  final String discountType;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  PromotionDto({
    required this.id,
    required this.title,
    required this.description,
    required this.discountType,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  /// Creates a [PromotionDto] from a JSON map
  factory PromotionDto.fromJson(Map<String, dynamic> json) {
    return PromotionDto(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      discountType: json['discount_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  /// Converts this [PromotionDto] to a JSON map
  Map<String, Object> toJson() {
    return <String, Object>{
      'id': id,
      'title': title,
      'description': description,
      'discount_type': discountType,
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
    };
  }
}
