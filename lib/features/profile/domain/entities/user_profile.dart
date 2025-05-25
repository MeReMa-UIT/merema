import 'package:equatable/equatable.dart';

// TODO: Add more fields as needed

class UserProfile extends Equatable {
  final String citizenId;
  final String email;
  final String phone;
  final String role;
  //final String infos

  const UserProfile({
    required this.citizenId,
    required this.email,
    required this.phone,
    required this.role,
    //required this.infos
  });

  @override
  List<Object?> get props => [
        citizenId,
        email,
        phone,
        role,
        //infos
      ];
}
