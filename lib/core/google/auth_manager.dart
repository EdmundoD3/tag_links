import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tag_links/core/google/drive_sync_config_manager.dart';
import 'package:tag_links/core/google/google_http_client.dart';

class AuthManager {
  final Ref _ref; // Ahora recibimos el Ref
  AuthManager(this._ref);

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  GoogleHttpClient? _httpClient; // Guardamos referencia para poder cerrarlo

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Propiedad calculada para obtener el manager de configuración

  final List<String> _driveScopes = const [drive.DriveApi.driveAppdataScope];

  GoogleSignInAccount? get currentUser => _currentUser;
  drive.DriveApi? get driveApi => _driveApi;

  /// Inicia el flujo de login manual interactivo
  Future<void> loginFlow() async {
    final GoogleSignInAccount? googleUser = await _interactiveGoogleLogin();
    if (googleUser == null) return;

    await _initializeDriveApi(googleUser);

    print("API de Drive inicializada correctamente.");
    await _checkInitialSync();
  }

  /// Intento de login silencioso al arrancar la app
Future<SilentLoginResult> trySilentLogin() async {
  try {
    final GoogleSignInAccount? user = await _googleSignIn
        .attemptLightweightAuthentication();

    if (user == null) return SilentLoginResult.noUser;

    final authorization = await user.authorizationClient
        .authorizationForScopes(_driveScopes);

    if (authorization == null) return SilentLoginResult.expired;

    await _initializeDriveApi(user);
    await _checkInitialSync();
    return SilentLoginResult.success;
    
  } catch (e) {
    if (e.toString().contains('network_error')) {
      return SilentLoginResult.networkError;
    }
    return SilentLoginResult.expired; // Por seguridad, si falla el auth, asumimos expirado
  }
}

  /// Encapsula la creación del cliente HTTP y la API de Drive
  Future<void> _initializeDriveApi(GoogleSignInAccount user) async {
    _currentUser = user;

    final Map<String, String>? authHeaders = await user.authorizationClient
        .authorizationHeaders(_driveScopes);

    if (authHeaders == null) {
      throw Exception("No se pudieron construir los headers de autorización.");
    }

    // Cerramos el cliente anterior si existía para evitar leaks
    _httpClient?.close();

    _httpClient = GoogleHttpClient(authHeaders);
    _driveApi = drive.DriveApi(_httpClient!);
  }

  Future<void> _checkInitialSync() async {
    final configManager = _ref.read(syncConfigProvider);
    if (configManager == null) return;

    final RemoteConfigData? remoteData = await configManager.getOrInitializeRemoteConfig();

    if (remoteData == null) {
      // Aquí es donde recuperamos el nivel: Informar al sistema que la nube está caída
      debugPrint(
        "🚨 Error: Auth exitoso pero Configuración de Drive inaccesible.",
      );
      // Podrías setear un flag en el Notifier: state = state.copyWith(hasCloudError: true);
      return;
    }

    debugPrint(
      "Sincronización de configuración lista: ${remoteData.config.devices.length} dispositivos registrados.",
    );
  }

  Future<GoogleSignInAccount?> _interactiveGoogleLogin() async {
    try {
    return await _googleSignIn.authenticate(scopeHint: _driveScopes); // Esto inicia el flujo visual
  } catch (error) {
    debugPrint("❌ Error en Google Login: $error");
    return null;
  }
  }

  /// Limpieza al cerrar sesión
  Future<void> logout() async {
    await _googleSignIn.signOut();
    _httpClient?.close();
    _currentUser = null;
    _driveApi = null;
  }
}

final authManagerProvider = Provider<AuthManager>((ref) {
  return AuthManager(ref);
});

enum SilentLoginResult {
  success,       // Todo bien
  noUser,        // Nunca ha iniciado sesión (primera vez)
  expired,       // Había sesión pero el token ya no sirve
  networkError,  // No hay internet para verificar
  timeout        // Google tardó demasiado
}