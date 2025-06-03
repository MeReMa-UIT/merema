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
    final accountInfos = json['account_info'] as Map<String, dynamic>;
    final additionalInfos = json['additional_info'];

    return UserProfileModel(
      citizenId: accountInfos['citizen_id'],
      email: accountInfos['email'],
      phone: accountInfos['phone'],
      role: accountInfos['role'],
      info: _parseInfo(additionalInfos),
    );
  }

  static Map<String, dynamic> _parseInfo(dynamic additionalInfos) {
    if (additionalInfos == null) {
      return {};
    }

    if (additionalInfos is List && additionalInfos.isNotEmpty) {
      final patientsInfos = additionalInfos.map((info) {
        final infoData = info as Map<String, dynamic>;
        return {
          'full_name': infoData['full_name'],
          'date_of_birth': infoData['date_of_birth'].toString(),
          'gender': infoData['gender'],
          'patient_id': infoData['patient_id'].toString(),
        };
      }).toList();

      return {
        'patients_infos': patientsInfos,
      };
    }

    final infoData = additionalInfos as Map<String, dynamic>;

    return {
      'full_name': infoData['full_name'],
      'date_of_birth': infoData['date_of_birth'].toString(),
      'gender': infoData['gender'],
      'staff_id': infoData['staff_id'].toString(),
      'department': infoData['department'],
    };
  }

  // TODO: Implement update profile use case
  Map<String, dynamic> toJson() {
    dynamic additionalInfos;

    if (info.containsKey('patients_infos')) {
      additionalInfos = info['patients_infos'];
    } else {
      additionalInfos = Map<String, dynamic>.from(info);
    }

    return {
      'account_info': {
        'citizen_id': citizenId,
        'email': email,
        'phone': phone,
        'role': role,
      },
      'additional_info': additionalInfos,
    };
  }
}
