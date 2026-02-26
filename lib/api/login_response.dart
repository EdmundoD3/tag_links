import 'package:tag_links/core/encypt/encrypted_datakey_model.dart';

class LoginResponse {
  final String token;
  final EncryptedDataKey? encryptedKey;
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
      encryptedKey: json['encryptedKey']? EncryptedDataKey.fromJson(json['encryptedKey']):null,
      premiumUntil: json['premiumUntil'],
      userName: json['userName'],
    );
  }
}
