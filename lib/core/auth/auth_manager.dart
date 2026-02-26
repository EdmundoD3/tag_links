import 'package:google_sign_in/google_sign_in.dart';
import 'package:tag_links/api/api_services.dart';
import 'package:tag_links/core/auth/token_storage.dart';
import 'package:tag_links/core/encypt/encrypt_storage.dart';
import 'package:tag_links/core/encypt/encrypted_datakey_model.dart';
import 'package:tag_links/core/encypt/encypter_services.dart';

class AuthData {
  final EncryptedDataKey? dataKey;
  final String? token;

  AuthData({required this.dataKey, required this.token});
}
class AuthManager {
  static final EncryptionService _encryptionService = EncryptionService();
  static final TokenStorage _tokenStorage = TokenStorage();
  static final EncryptStorage _encryptStorage = EncryptStorage();

  static Future<void> loginFlow({
    required Future<String> Function() askPin,
  }) async {

    // 1️⃣ Google login obligatorio
    final idToken = await _interactiveGoogleLogin();
    if (idToken == null) {
      throw Exception("Google login cancelado");
    }

    // 2️⃣ Login en API
    final response = await ApiServices.login(idToken: idToken);
    if (response.data == null) {
      throw Exception("Login fallido");
    }

    final token = response.data!.token;
    final encryptedKey = response.data!.encryptedKey;

    if (token != null) {
      await _tokenStorage.save(token);
    }

    if (encryptedKey == null) {
      await _firstLoginFlow(idToken:idToken, token: token!,askPin:askPin);
    } else {
      await _normalLoginFlow(encryptedKey, askPin);
    }
  }

  // -----------------------------------------------------

  static Future<void> _firstLoginFlow(
    {required String idToken,
    required String token,
     required Future<String> Function() askPin,}
  ) async {

    final pin = await askPin();

    // Generar nueva DataKey
    final encryptedDataKey =
        await _encryptionService.generateDataKey(pin);

    // Guardar localmente
    await _encryptStorage.set(encryptedDataKey);

    // Registrar encryptedKey en servidor
    await ApiServices.registerEncryptedKey(encryptedKey:encryptedDataKey, accessToken: token);

    // Cache en memoria
    await _encryptionService.unlock(pin);
  }

  // -----------------------------------------------------

  static Future<void> _normalLoginFlow(
    EncryptedDataKey encryptedKey,
    Future<String> Function() askPin,
  ) async {

    // Guardar encryptedKey del servidor
    await _encryptStorage.set(encryptedKey);

    final pin = await askPin();

    try {
      await _encryptionService.unlock(pin);
    } catch (_) {
      throw Exception("PIN incorrecto");
    }
  }

  // -----------------------------------------------------

  static Future<String?> _interactiveGoogleLogin() async {
    final googleSignIn = GoogleSignIn.instance;
    final account = await googleSignIn.authenticate();

    if (account == null) return null;

    final auth = account.authentication;
    return auth.idToken;
  }
}