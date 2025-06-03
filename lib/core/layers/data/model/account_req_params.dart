class AccountReqParams {
  final String citizenId;
  final String email;
  final String phone;
  final String role;

  AccountReqParams({
    required this.citizenId,
    required this.email,
    required this.phone,
    this.role = 'patient',
  });

  Map<String, dynamic> toJson() => {
        'citizen_id': citizenId,
        'email': email,
        'phone': phone,
        'role': role,
      };
}
