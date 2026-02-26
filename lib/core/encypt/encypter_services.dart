import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:tag_links/core/encypt/encrypt_storage.dart';
import 'package:tag_links/core/encypt/encrypted_datakey_model.dart';

class EncryptionService {
  EncryptionService();

  static final _algorithm = AesGcm.with256bits();

  final EncryptStorage _encryptedStorage = EncryptStorage();
  final DatakeyStorage _plainStorage = DatakeyStorage();

  /// 🔐 Vive SOLO en memoria (RAM)
  SecretKey? _cachedDataKey;

  // ----------------------------------------------------------------
  // 🔓 Desbloquea la sesión (requiere PIN)
  Future<void> unlock(String pin) async {
    final secretKey = await unlockDataKey(pin);

    _cachedDataKey = secretKey;

    // 🔥 Guardamos la versión desencriptada para no pedir PIN otra vez
    final bytes = await secretKey.extractBytes();
    await _plainStorage.savePlainDataKey(bytes);
  }

  // ----------------------------------------------------------------
  // 🚀 Intentar desbloqueo automático (sin PIN)
  Future<bool> tryAutoUnlock() async {
    final storedBytes = await _plainStorage.getPlainDataKey();

    if (storedBytes == null) return false;

    _cachedDataKey = SecretKey(storedBytes);
    return true;
  }

  // ----------------------------------------------------------------
  // 🆕 Genera una nueva DataKey (primer login)
  Future<EncryptedDataKey> generateDataKey(String pin) async {
    final dataKey = await _algorithm.newSecretKey();
    final dataKeyBytes = await dataKey.extractBytes();

    final salt = _generateSalt();
    final masterKey = await deriveMasterKey(pin, salt);

    final secretBox = await _algorithm.encrypt(
      dataKeyBytes,
      secretKey: masterKey,
    );

    final encryptedDataKey = EncryptedDataKey(
      cipherText: secretBox.cipherText,
      nonce: secretBox.nonce,
      mac: secretBox.mac.bytes,
      salt: salt,
    );

    // Guardar versión cifrada (respaldo)
    await _encryptedStorage.set(encryptedDataKey);

    // 🔥 Guardar versión desencriptada (UX)
    await _plainStorage.savePlainDataKey(dataKeyBytes);

    _cachedDataKey = SecretKey(dataKeyBytes);

    return encryptedDataKey;
  }

  // ----------------------------------------------------------------
  Future<String> encrypt(String plainText) async {
    final secretKey = await _getSecretKey();

    final secretBox = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
    );

    final combined = {
      'cipherText': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
    };

    return jsonEncode(combined);
  }

  // ----------------------------------------------------------------
  Future<String> decrypt(String encryptedText) async {
    final secretKey = await _getSecretKey();

    final decodedJson = jsonDecode(encryptedText);

    final cipherText = base64Decode(decodedJson['cipherText']);
    final nonce = base64Decode(decodedJson['nonce']);
    final mac = Mac(base64Decode(decodedJson['mac']));

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);

    final clearBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearBytes);
  }

  // ----------------------------------------------------------------
  Future<SecretKey> deriveMasterKey(String password, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 250000,
      bits: 256,
    );

    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  // ----------------------------------------------------------------
  Future<SecretKey> unlockDataKey(String pin) async {
    final encryptedDataKey = await _encryptedStorage.get();

    if (encryptedDataKey == null) {
      throw Exception("No encryption key found");
    }

    final masterKey = await deriveMasterKey(pin, encryptedDataKey.salt);

    final secretBox = SecretBox(
      encryptedDataKey.cipherText,
      nonce: encryptedDataKey.nonce,
      mac: Mac(encryptedDataKey.mac),
    );

    final dataKeyBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: masterKey,
    );

    return SecretKey(dataKeyBytes);
  }

  // ----------------------------------------------------------------
  Future<void> rotatePin(String oldPin, String newPin) async {
    final currentDataKey = await unlockDataKey(oldPin);
    final dataKeyBytes = await currentDataKey.extractBytes();

    final newSalt = _generateSalt();
    final newMasterKey = await deriveMasterKey(newPin, newSalt);

    final secretBox = await _algorithm.encrypt(
      dataKeyBytes,
      secretKey: newMasterKey,
    );

    final newEncryptedDataKey = EncryptedDataKey(
      cipherText: secretBox.cipherText,
      nonce: secretBox.nonce,
      mac: secretBox.mac.bytes,
      salt: newSalt,
    );

    await _encryptedStorage.set(newEncryptedDataKey);

    // 🔥 También actualizar plain
    await _plainStorage.savePlainDataKey(dataKeyBytes);

    _cachedDataKey = SecretKey(dataKeyBytes);
  }

  // ----------------------------------------------------------------
  Future<void> logoutCleanup() async {
    await _plainStorage.clearPlainDataKey();
    await _encryptedStorage.clean();
    _cachedDataKey = null;
  }

  // ----------------------------------------------------------------
  Future<SecretKey> _getSecretKey() async {
    if (_cachedDataKey == null) await tryAutoUnlock();
    if (_cachedDataKey == null) {
      throw Exception("Encryption locked. Unlock first.");
    }
    return _cachedDataKey!;
  }

  // ----------------------------------------------------------------
  List<int> _generateSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  // -----------------------------------------------------------------
  // Permite crear un servicio con una llave ya existente (útil para el Isolate)
  EncryptionService.fromBytes(List<int> bytes) {
    _cachedDataKey = SecretKey(bytes);
  }

  // Permite extraer la llave de memoria para enviarla al Isolate
  Future<List<int>> getRawKeyBytes() async {
    final key = await _getSecretKey();
    return await key.extractBytes();
  }
}
