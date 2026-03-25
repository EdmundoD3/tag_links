import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tag_links/core/google/drive_sync_config_manager.dart';
import 'package:tag_links/core/google/google_http_client.dart';
import 'package:tag_links/sync/models/config_info.dart';

class AuthManager {
  final DriveSyncConfigManager? _configManager;
  AuthManager(this._configManager);

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
    final GoogleSignInAccount googleUser = await _interactiveGoogleLogin();
    await _initializeDriveApi(googleUser);

    print("API de Drive inicializada correctamente.");
    await _checkInitialSync();
  }

  /// Intento de login silencioso al arrancar la app
  Future<bool> trySilentLogin() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn
          .attemptLightweightAuthentication();

      if (user != null) {
        final authorization = await user.authorizationClient
            .authorizationForScopes(_driveScopes);

        if (authorization != null) {
          await _initializeDriveApi(user);
          print("✅ Sesión silenciosa recuperada: ${user.email}");

          // Opcional: Ejecutar sincronización inicial de fondo
          await _checkInitialSync();
          return true;
        }
      }
    } catch (e) {
      print("❌ Error en trySilentLogin: $e");
    }
    return false;
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
    if (_configManager == null) return;

    final ConfigInfo? config = await _configManager.checkAndInitializeConfig();

    if (config == null) {
      // Aquí es donde recuperamos el nivel: Informar al sistema que la nube está caída
      debugPrint(
        "🚨 Error: Auth exitoso pero Configuración de Drive inaccesible.",
      );
      // Podrías setear un flag en el Notifier: state = state.copyWith(hasCloudError: true);
      return;
    }

    debugPrint(
      "Sincronización de configuración lista: ${config.devices.length} dispositivos registrados.",
    );
  }

  Future<GoogleSignInAccount> _interactiveGoogleLogin() async {
    return await _googleSignIn.authenticate(scopeHint: _driveScopes);
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
  final configManager = ref.watch(syncConfigProvider);
  return AuthManager(configManager);
});
