import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String citizenId;
  final String email;
  final String phone;
  final String role;
  final Map<String, dynamic> info;

  const UserProfile(
      {required this.citizenId,
      required this.email,
      required this.phone,
      required this.role,
      required this.info});

  @override
  List<Object?> get props => [citizenId, email, phone, role, info];
}
