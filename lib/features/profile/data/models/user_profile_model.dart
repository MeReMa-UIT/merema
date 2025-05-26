import 'package:merema/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.citizenId,
    required super.email,
    required super.phone,
    required super.role,
    required super.info,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final accountInfo = json['account_info'] as Map<String, dynamic>;
    final additionalInfo =
        json['additional_info'] as Map<String, dynamic>; // TODO: Handle list response

    return UserProfileModel(
      citizenId: accountInfo['citizen_id'],
      email: accountInfo['email'],
      phone: accountInfo['phone'],
      role: accountInfo['role'],
      info: _parseInfo(additionalInfo, accountInfo['role']),
    );
  }

  static Map<String, dynamic> _parseInfo(
      Map<String, dynamic> additionalInfo, String role) {
    final temp = {
      'full_name': additionalInfo['full_name'],
      'date_of_birth': additionalInfo['date_of_birth'].toString(),
      'gender': additionalInfo['gender'],
    };

    if (role == 'patient') {
      temp['patient_id'] = additionalInfo['patient_id'].toString();
    } else {
      temp['staff_id'] = additionalInfo['staff_id'].toString();
      temp['department'] = additionalInfo['department'];
    }

    return temp;
  }

  Map<String, dynamic> toJson() {
    final additionalInfo = Map<String, dynamic>.from(info);

    return {
      'account_info': {
        'citizen_id': citizenId,
        'email': email,
        'phone': phone,
        'role': role,
      },
      'additional_info': additionalInfo,
    };
  }

  UserProfileModel copyWith({
    String? citizenId,
    String? email,
    String? phone,
    String? role,
    Map<String, String>? info,
  }) {
    return UserProfileModel(
      citizenId: citizenId ?? this.citizenId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      info: info ?? this.info,
    );
  }
}
