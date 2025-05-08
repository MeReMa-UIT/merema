class LoginReqParams {
  final String email;
  final String password;

  LoginReqParams({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': email,
      'password': password,
    };
  }
}

class RecoveryReqParams {
  final String citizenId;
  final String email;

  RecoveryReqParams({
    required this.citizenId,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'citizen_id': citizenId,
      'email': email,
    };
  }
}

class RecoveryConfirmReqParams {
  final String citizenId;
  final String otp;

  RecoveryConfirmReqParams({
    required this.citizenId,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'citizen_id': citizenId,
      'otp': otp,
    };
  }
}

class RecoveryResetReqParams {
  final String token;
  final String newPassword;

  RecoveryResetReqParams({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'new_password': newPassword,
    };
  }
}
