import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tag_links/core/encypt/encrypted_datakey_model.dart';

class EncryptStorage {
  static const _key = 'encrypted_data_key';

  final FlutterSecureStorage _secureStorage;

  EncryptStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Guarda la EncryptedDataKey en secure storage
  Future<void> set(EncryptedDataKey dataKey) async {
    final jsonString = jsonEncode(dataKey.toJson());
    await _secureStorage.write(
      key: _key,
      value: jsonString,
    );
  }

  /// Obtiene la EncryptedDataKey almacenada
  Future<EncryptedDataKey?> get() async {
    final jsonString = await _secureStorage.read(key: _key);

    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    return EncryptedDataKey.fromJson(jsonMap);
  }

  /// Elimina la clave almacenada
  Future<bool> clean() async {
    await _secureStorage.delete(key: _key);
    return true;
  }
}

class DatakeyStorage {
  static const _secureStorage = FlutterSecureStorage();

  static const _plainDataKeyKey = 'plain_data_key';

  // ----------------------------------------------------------------
  /// 🔐 Guarda la DataKey ya desencriptada en Secure Storage
  Future<void> savePlainDataKey(List<int> bytes) async {
    final encoded = base64Encode(bytes);

    await _secureStorage.write(
      key: _plainDataKeyKey,
      value: encoded,
    );
  }

  // ----------------------------------------------------------------
  /// 🔓 Obtiene la DataKey guardada
  Future<List<int>?> getPlainDataKey() async {
    final encoded = await _secureStorage.read(
      key: _plainDataKeyKey,
    );

    if (encoded == null) return null;

    return base64Decode(encoded);
  }

  // ----------------------------------------------------------------
  /// 🗑 Borra la DataKey (logout o reset)
  Future<void> clearPlainDataKey() async {
    await _secureStorage.delete(
      key: _plainDataKeyKey,
    );
  }
}