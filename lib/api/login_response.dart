class LoginResponse {
  final String token;
  final Map<String, dynamic>? encryptedKey;
  final int? premiumUntil;
  final String? userName;

  LoginResponse({
    required this.token,
    this.encryptedKey,
    this.premiumUntil,
    this.userName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      encryptedKey: json['encryptedKey'],
      premiumUntil: json['premiumUntil'],
      userName: json['userName'],
    );
  }
}
