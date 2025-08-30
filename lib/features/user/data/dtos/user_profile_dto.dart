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
    String _s(dynamic v) => (v ?? '').toString();
    String? _sn(dynamic v) {
      final s = v?.toString();
      return (s == null || s.isEmpty) ? null : s;
    }
    DateTime? _dt(dynamic v) { if (v == null) return null; try { return DateTime.parse(v.toString()); } catch (_) { return null; } }

    return UserProfileDto(
      id: _s(json['id'] ?? json['uuid'] ?? json['pk']),
      email: _s(json['email']),
      firstName: _sn(json['first_name'] ?? json['firstname']),
      lastName: _sn(json['last_name'] ?? json['lastname']),
      nickname: _sn(json['nickname'] ?? json['username'] ?? json['handle']),
      address: _sn(json['address']),
      city: _sn(json['city']),
      state: _sn(json['state']),
      zipCode: _sn(json['zip_code'] ?? json['zipcode'] ?? json['postal_code']),
      country: _sn(json['country']),
      phone: _sn(json['phone']),
      registrationNumber: _sn(json['sign_up_number']),
      firstIp: _sn(json['first_ip']),
      secondIp: _sn(json['second_ip']),
      avatarUrl: _sn(json['avatar'] ?? json['avatar_url'] ?? json['photo']),
      createdAt: _dt(json['created_at']),
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
