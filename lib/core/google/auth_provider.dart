import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:tag_links/core/google/auth_manager.dart';

class AuthState {
  final GoogleSignInAccount? user;
  final DriveApi? driveApi;
  final bool isLoading;

  AuthState({this.user, this.driveApi, this.isLoading = false});

  // Ahora es más robusto verificar la autenticación
  bool get isAuthenticated => user != null && driveApi != null;
  static AuthState voidState(){
    return AuthState(isLoading: true);
  }
}

class AuthNotifier extends Notifier<AuthState> {
  // Instanciamos el manager que acabamos de pulir
AuthManager get _authManager => ref.read(authManagerProvider);

  @override
  AuthState build() {
    // 2. Iniciamos el silent login de fondo sin bloquear el hilo principal
    _initSilentLogin();
    
    // Estado inicial mientras se intenta el login silencioso
    return AuthState(isLoading: true);
  }
  Future<void> _initSilentLogin() async {
    final success = await _authManager.trySilentLogin();
    
    // Actualizamos el estado con lo que haya pasado
    state = AuthState(
      user: _authManager.currentUser,
      driveApi: _authManager.driveApi,
      isLoading: false,
    );
  }

  Future<void> init() async {
    // trySilentLogin ya hace el check de scopes e inicializa la API internamente
    final success = await _authManager.trySilentLogin();
    
    if (success) {
      state = AuthState(
        user: _authManager.currentUser,
        driveApi: _authManager.driveApi,
        isLoading: false,
      );
    } else {
      state = AuthState(isLoading: false);
    }
  }

Future<void> login() async {
    state = AuthState(isLoading: true);
    try {
      await _authManager.loginFlow();
      state = AuthState(
        user: _authManager.currentUser,
        driveApi: _authManager.driveApi,
        isLoading: false,
      );
    } catch (e) {
      debugPrint("❌ Error en el login: $e");
      state = AuthState(isLoading: false);
    }
  }

Future<void> logout() async {
    state = AuthState(isLoading: true);
    await _authManager.logout();
    state = AuthState(isLoading: false, user: null, driveApi: null);
  }
  

}

// Cambié el import de legacy por el estándar de Riverpod
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);