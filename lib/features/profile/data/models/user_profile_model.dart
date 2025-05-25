import 'package:merema/features/profile/domain/entities/user_profile.dart';

// TODO: Add more fields as needed

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.citizenId,
    required super.email,
    required super.phone,
    required super.role,
    //required super.infos
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      citizenId: json['citizen_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      //infos: json['infos'] ?? const {}
    );
  }

  // For update profile
  Map<String, dynamic> toJson() {
    return {
      'citizen_id': citizenId,
      'email': email,
      'phone': phone,
      'role': role,
      //'infos': infos
    };
  }

  UserProfileModel copyWith({
    required citizenId,
    required email,
    required phone,
    required role,
    // required infos
  }) {
    return UserProfileModel(
      citizenId: citizenId ?? this.citizenId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }
}
