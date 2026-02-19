import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

class PinEncryptionUtil {
  static final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 250000,
    bits: 256,
  );

  static final _aes = AesGcm.with256bits();

  /// Genera una dataKey aleatoria (32 bytes)
  static Future<SecretKey> generateDataKey() async {
    return _aes.newSecretKey();
  }

  /// Genera salt aleatorio
  static List<int> generateSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (i) => random.nextInt(256));
  }

  /// Deriva clave desde PIN + salt
  static Future<SecretKey> deriveKeyFromPin({
    required String pin,
    required List<int> salt,
  }) async {
    return _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
  }

  /// Encripta dataKey con clave derivada del PIN
  static Future<EncryptedDataKey> encryptDataKey({
    required SecretKey dataKey,
    required SecretKey pinKey,
  }) async {
    final dataKeyBytes = await dataKey.extractBytes();

    final encrypted = await _aes.encrypt(
      dataKeyBytes,
      secretKey: pinKey,
    );

    return EncryptedDataKey(
      cipherText: encrypted.cipherText,
      nonce: encrypted.nonce,
      mac: encrypted.mac.bytes,
    );
  }

  /// Desencripta dataKey usando PIN
  static Future<SecretKey> decryptDataKey({
    required EncryptedDataKey encryptedDataKey,
    required SecretKey pinKey,
  }) async {
    final secretBox = SecretBox(
      encryptedDataKey.cipherText,
      nonce: encryptedDataKey.nonce,
      mac: Mac(encryptedDataKey.mac),
    );

    final decryptedBytes = await _aes.decrypt(
      secretBox,
      secretKey: pinKey,
    );

    return SecretKey(decryptedBytes);
  }
}

class EncryptedDataKey {
  final List<int> cipherText;
  final List<int> nonce;
  final List<int> mac;

  EncryptedDataKey({
    required this.cipherText,
    required this.nonce,
    required this.mac,
  });
}
