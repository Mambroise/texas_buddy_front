//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/domain/entities/interst_category.dart
// Author : Morice
//-------------------------------------------------------------------------

class InterestCategory {
  final int id;
  final String name;
  final String? icon;        // ex: "fa-music"
  final String? description;

  const InterestCategory({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });
}
