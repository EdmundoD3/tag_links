import 'dart:convert';

class EncryptedDataKey {
  final List<int> cipherText;
  final List<int> nonce;
  final List<int> mac;
  final List<int> salt;

  EncryptedDataKey({
    required this.cipherText,
    required this.nonce,
    required this.mac,
    required this.salt,
  });

  /// Opcional: útil para guardar en JSON
  Map<String, dynamic> toJson() => {
        'cipherText': base64Encode(cipherText),
        'nonce': base64Encode(nonce),
        'mac': base64Encode(mac),
        'salt': base64Encode(salt),
      };

  factory EncryptedDataKey.fromJson(Map<String, dynamic> json) {
    return EncryptedDataKey(
      cipherText: base64Decode(json['cipherText']),
      nonce: base64Decode(json['nonce']),
      mac: base64Decode(json['mac']),
      salt: base64Decode(json['salt']),
    );
  }
}