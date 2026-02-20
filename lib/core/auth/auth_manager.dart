import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/api/api_services.dart';

class AuthManager {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await _googleSignIn.initialize();
    _initialized = true;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    await _googleSignIn.signOut();
  }

  /// Login interactivo (botón)
  static Future<ApiLoginStatus?> interactiveLogin() async {
    try {
      final account = await _googleSignIn.authenticate();
      final auth = account.authentication;
      return await _exchangeWithBackend(auth.idToken);
    } catch (_) {
      return null;
    }
  }

  /// 🔥 Login silencioso (para refresh mensual)
  static Future<ApiLoginStatus?> silentReLogin() async {
    try {
      final account = await _googleSignIn.attemptLightweightAuthentication();

      if (account == null) {
        return null; // No hay sesión Google activa
      }

      final auth = account.authentication;
      return await _exchangeWithBackend(auth.idToken);
    } catch (_) {
      return null;
    }
  }

  /// Guarda JWT de tu backend
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', token);
  }

  /// Envía idToken a tu backend
  static Future<ApiLoginStatus?> _exchangeWithBackend(
    String? idToken,
  ) async {
    if (idToken == null) return null;
    final response = await ApiServices.login(idToken: idToken);

    if (!response.isSucces) {
      return response.status;
    }

    await _saveToken(response.data!.token);
    return ApiLoginStatus.ok;
  }
}
