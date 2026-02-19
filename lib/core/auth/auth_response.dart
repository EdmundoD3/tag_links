import 'package:tag_links/core/auth/data_key.dart';

class AuthResponse {
  final String token;
  final DataKey encryptedKey;

  AuthResponse({required this.token, required this.encryptedKey});
}
extension AuthResponseX on AuthResponse {
  bool get isFirstLogin => encryptedKey == null;
}
