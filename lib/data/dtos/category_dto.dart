//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/dtos/category_dto.dart
// Author : Morice
//-------------------------------------------------------------------------


/// Data Transfer Object for category data
class CategoryDto {
  final int id;
  final String name;
  final String? icon;
  final String? description;

  CategoryDto({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });

  /// Creates a [CategoryDto] from a JSON map
  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }

  /// Converts this [CategoryDto] to a JSON map
  Map<String, Object?> toJson() {
    return <String, Object?> {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }
}

