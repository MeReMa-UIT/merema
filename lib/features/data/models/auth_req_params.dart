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
  final String email;

  RecoveryReqParams({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class RecoveryConfirmReqParams {
  final String token;
  final String otp;

  RecoveryConfirmReqParams({
    required this.token,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
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
      'token': token,
      'new_password': newPassword,
    };
  }
}
