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

  Future<SilentLoginResult> trySilentLogin() async {
    try {
      // 1. Intento recuperar al usuario (Identity)
      final GoogleSignInAccount? user = await _googleSignIn
          .attemptLightweightAuthentication();

      if (user == null) return SilentLoginResult.noUser;

      // 2. Verificamos si tenemos tokens válidos para Drive SIN MOSTRAR UI
      // Usamos authorizationHeaders con promptIfNecessary: false para que sea "silencioso"
      final authHeaders = await user.authorizationClient.authorizationHeaders(
        _driveScopes,
        promptIfNecessary: false,
      );

      // Si es null, significa que el token no existe, expiró
      // o el usuario no ha dado permiso para Drive.
      if (authHeaders == null) return SilentLoginResult.expired;

      // 3. Si llegamos aquí, tenemos usuario y tenemos llave de Drive
      await _initializeDriveApi(user);
      await _checkInitialSync();

      return SilentLoginResult.success;
      // En trySilentLogin
    } catch (e) {
      debugPrint("⚠️ Error en silent login: $e");

      // Si el error es específicamente de red, GoogleSignIn suele lanzar
      // excepciones que podemos identificar.
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('network') || errorStr.contains('socket')) {
        return SilentLoginResult.networkError;
      }

      // Para cualquier otra cosa (token inválido, revocado, etc)
      return SilentLoginResult.expired;
    }
  }

  /// Encapsula la creación del cliente HTTP y la API de Drive
  Future<void> _initializeDriveApi(GoogleSignInAccount user) async {
    _currentUser = user;

    final Map<String, String>? authHeaders = await user.authorizationClient
        .authorizationHeaders(
          _driveScopes,
          promptIfNecessary: false, // <--- LA CLAVE
        );

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

    final RemoteConfigData? remoteData = await configManager
        .getOrInitializeRemoteConfig();

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
      // 1. LOGIN DE IDENTIDAD
      // Usamos authenticate() para que el usuario elija su cuenta.
      // Pasamos _driveScopes como 'scopeHint' para que, si el sistema lo permite,
      // pida todo de una vez.
      final GoogleSignInAccount user = await _googleSignIn.authenticate(
        scopeHint: _driveScopes,
      );

      debugPrint("✅ Usuario autenticado: ${user.email}");

      // 2. SOLICITUD DE AUTORIZACIÓN (HEADERS)
      // Aquí es donde obtenemos los tokens para Drive.
      // 'promptIfNecessary: true' es el secreto: si el usuario no ha marcado
      // la casilla de Drive, esto obligará a que aparezca la ventana.
      final Map<String, String>? authHeaders = await user.authorizationClient
          .authorizationHeaders(_driveScopes, promptIfNecessary: true);

      if (authHeaders == null) {
        debugPrint(
          "❌ Error: No se otorgaron permisos de Drive (Headers nulos).",
        );
        return null;
      }

      debugPrint("✅ Autorización de Drive lista.");
      return user;
    } catch (error) {
      debugPrint("❌ Error en el flujo de Google Login: $error");
      return null;
    }
  }

  /// Limpieza al cerrar sesión
  Future<void> logout() async {
    await _googleSignIn.signOut();
    _httpClient?.close();
    _httpClient =
        null; // Agrégalo para evitar intentar usar un cliente cerrado después
    _currentUser = null;
    _driveApi = null;
  }
}

final authManagerProvider = Provider<AuthManager>((ref) {
  return AuthManager(ref);
});

enum SilentLoginResult {
  success, // Todo bien
  noUser, // Nunca ha iniciado sesión (primera vez)
  expired, // Había sesión pero el token ya no sirve
  networkError, // No hay internet para verificar
  timeout, // Google tardó demasiado
}
