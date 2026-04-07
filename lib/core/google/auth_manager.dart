import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class AuthManager {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final List<String> _driveScopes = const [drive.DriveApi.driveAppdataScope];

  // 1. Intento silencioso: Solo devuelve el usuario si ya existe
  Future<GoogleSignInAccount?> getSilentUser() async {
    return await _googleSignIn.attemptLightweightAuthentication();
  }

  // 2. Login interactivo: Abre la ventanita
  Future<GoogleSignInAccount?> getInteractiveUser() async {
    return await _googleSignIn.authenticate(scopeHint: _driveScopes);
  }

  // 3. Obtener Headers: La herramienta para crear el cliente
  Future<Map<String, String>?> getHeaders(GoogleSignInAccount user, {bool forcePrompt = false}) async {
    return await user.authorizationClient.authorizationHeaders(
      _driveScopes,
      promptIfNecessary: forcePrompt,
    );
  }

  // 4. Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

final authManagerProvider = Provider<AuthManager>((ref) => AuthManager());