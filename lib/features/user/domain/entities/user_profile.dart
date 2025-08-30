//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/domain/entities/user_page.dart
// Author : Morice
//-------------------------------------------------------------------------


class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? nickname;

  // Adresse
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? phone;

  // 👇 Nouveaux champs
  final String? registrationNumber; // sign_up_number
  final String? firstIp;
  final String? secondIp;

  final String? avatarUrl;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.nickname,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.phone,
    this.registrationNumber,
    this.firstIp,
    this.secondIp,
    this.avatarUrl,
    this.createdAt,
  });
}
