import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class AuthManager {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final List<String> _driveScopes = const [drive.DriveApi.driveAppdataScope];

  // Opcional pero muy recomendado: Inicializar la instancia en tu main o provider
  Future<void> initialize() async {
    await _googleSignIn.initialize();
  }

  // 1. Intento silencioso: Solo devuelve el usuario si ya existe y NO requiere interfaz
  Future<GoogleSignInAccount?> getSilentUser() async {
    final bool requiereUI = _googleSignIn.authorizationRequiresUserInteraction();
    
    if (requiereUI) {
      debugPrint("⛔ [SilentUser] El sistema indica que se requiere interacción del usuario. Abortando.");
      return null;
    }

    try {
      final cuenta = await _googleSignIn.attemptLightweightAuthentication();
      return cuenta;
    } catch (e) {
      debugPrint("⚠️ [SilentUser] Error en autenticación ligera: $e");
      return null;
    }
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
    
    // 🛡️ ESCUDO IMPRESCINDIBLE: Si no estamos forzando la interfaz, comprobamos
    // si el llavero nativo va a necesitar levantar un modal para refrescar scopes.
    if (!forcePrompt) {
      final bool requiereUI = _googleSignIn.authorizationRequiresUserInteraction();
      if (requiereUI) {
        debugPrint("⛔ [getHeaders] Se detectó que renovar tokens requerirá UI. Abortando en silencio.");
        return null; // Devolver null obligará a arrojar DrivePermissionDeniedException de forma segura
      }
    }

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
