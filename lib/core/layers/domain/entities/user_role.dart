enum UserRole {
  admin,
  doctor,
  patient,
  receptionist,
  noRole,
}

extension UserRoleExtension on UserRole {
  static UserRole fromString(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'doctor':
        return UserRole.doctor;
      case 'patient':
        return UserRole.patient;
      case 'receptionist':
        return UserRole.receptionist;
      default:
        return UserRole.noRole;
    }
  }
}
