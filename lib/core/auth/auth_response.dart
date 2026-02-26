
import 'package:tag_links/core/encypt/encrypted_datakey_model.dart';

class AuthResponse {
  final String token;
  final EncryptedDataKey encryptedKey;

  AuthResponse({required this.token, required this.encryptedKey});
}