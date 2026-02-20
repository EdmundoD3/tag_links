class DataKey {
  final String ciphertext;
  final String nonce;
  final String mac;
  final String salt;

  DataKey({required this.ciphertext, required this.nonce, required this.mac, required this.salt});
  
}
class AuthResponse {
  final String token;
  final DataKey encryptedKey;

  AuthResponse({required this.token, required this.encryptedKey});
}
extension AuthResponseX on AuthResponse {
  bool get isFirstLogin => encryptedKey == null;
}
