import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class AuthManager {
final GoogleSignIn _googleSignIn; // Recibido por constructor
  final List<String> _driveScopes = const [drive.DriveApi.driveAppdataScope];

  // Constructor limpio
  AuthManager(this._googleSignIn);

  // 1. Intento silencioso: Solo devuelve el usuario si ya existe y NO requiere interfaz
  Future<GoogleSignInAccount?> getSilentUser() async {
    //ahora no verificaremos si es posible hacerlo silencioso
    return await _googleSignIn.attemptLightweightAuthentication();
  }

  // 2. Login interactivo: Abre la ventanita de forma intencional
  Future<GoogleSignInAccount?> getInteractiveUser() async {
    return await _googleSignIn.authenticate(scopeHint: _driveScopes);
  }

  // 3. Obtener Headers: Protegido contra prompts automáticos del sistema
  Future<Map<String, String>?> getHeaders(
    GoogleSignInAccount user, {
    bool forcePrompt = false,
  }) async {
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
// Dejamos en claro que este provider DEBE ser sobreescrito en el main.
// No necesita retornar GoogleSignIn.instance por defecto, porque el main se encargará.
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  throw UnimplementedError('googleSignInProvider no ha sido inicializado en el ProviderScope');
});

final authManagerProvider = Provider<AuthManager>((ref) => AuthManager(ref.watch(googleSignInProvider)));
