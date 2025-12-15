//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/data/dtos/user_profile_dto.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';

class UserProfileDto {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? nickname;

  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? phone;

  // 👇 Ajoutés
  final String? registrationNumber; // sign_up_number
  final String? firstIp;
  final String? secondIp;

  final String? avatarUrl;
  final DateTime? createdAt;

  UserProfileDto({
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

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => (v ?? '').toString();
    String? sn(dynamic v) {
      final s = v?.toString();
      return (s == null || s.isEmpty) ? null : s;
    }
    DateTime? dt(dynamic v) { if (v == null) return null; try { return DateTime.parse(v.toString()); } catch (_) { return null; } }

    return UserProfileDto(
      id: s(json['id'] ?? json['uuid'] ?? json['pk']),
      email: s(json['email']),
      firstName: sn(json['first_name'] ?? json['firstname']),
      lastName: sn(json['last_name'] ?? json['lastname']),
      nickname: sn(json['nickname'] ?? json['username'] ?? json['handle']),
      address: sn(json['address']),
      city: sn(json['city']),
      state: sn(json['state']),
      zipCode: sn(json['zip_code'] ?? json['zipcode'] ?? json['postal_code']),
      country: sn(json['country']),
      phone: sn(json['phone']),
      registrationNumber: sn(json['sign_up_number']),
      firstIp: sn(json['first_ip']),
      secondIp: sn(json['second_ip']),
      avatarUrl: sn(json['avatar'] ?? json['avatar_url'] ?? json['photo']),
      createdAt: dt(json['created_at']),
    );
  }

  UserProfile toDomain() => UserProfile(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    nickname: nickname,
    address: address,
    city: city,
    state: state,
    zipCode: zipCode,
    country: country,
    phone: phone,
    registrationNumber: registrationNumber,
    firstIp: firstIp,
    secondIp: secondIp,
    avatarUrl: avatarUrl,
    createdAt: createdAt,
  );

  Map<String, dynamic> toDb() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'nickname': nickname,
    'address': address,
    'city': city,
    'state': state,
    'zip_code': zipCode,
    'country': country,
    'phone': phone,
    'registration_number': registrationNumber,
    'first_ip': firstIp,
    'second_ip': secondIp,
    'avatar_url': avatarUrl,
    'created_at': createdAt?.toIso8601String(),
  };

  static UserProfileDto fromDb(Map<String, dynamic> row) => UserProfileDto(
    id: row['id'] as String,
    email: row['email'] as String,
    firstName: row['first_name'] as String?,
    lastName: row['last_name'] as String?,
    nickname: row['nickname'] as String?,
    address: row['address'] as String?,
    city: row['city'] as String?,
    state: row['state'] as String?,
    zipCode: row['zip_code'] as String?,
    country: row['country'] as String?,
    phone: row['phone'] as String?,
    registrationNumber: row['registration_number'] as String?,
    firstIp: row['first_ip'] as String?,
    secondIp: row['second_ip'] as String?,
    avatarUrl: row['avatar_url'] as String?,
    createdAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'] as String) : null,
  );
}
