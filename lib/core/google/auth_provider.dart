import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:tag_links/core/auth/skiped_auth_provider.dart';
import 'package:tag_links/core/google/auth_manager.dart';

class AuthNotifier extends Notifier<AuthState> {
  // Instanciamos el manager que acabamos de pulir
  AuthManager get _authManager => ref.read(authManagerProvider);

  @override
  AuthState build() {
    // Iniciamos en false para que el Router nos mande directo a HomePage
    // El proceso de login ocurre en el fondo.
    _initSilentLogin();
    return AuthState(isLoading: false);
  }

  Future<void> _initSilentLogin() async {
    final hasSkipped = ref.read(skipedAuthProvider);
    if (hasSkipped == true) {
      state = AuthState(
        user: null,
        driveApi: null,
        isLoading: false,
        lastResult: null,
      );
      return;
    }

    final result = await _authManager.trySilentLogin().timeout(
      const Duration(seconds: 5),
      onTimeout: () => SilentLoginResult.timeout,
    );
    if(result == SilentLoginResult.success) {
      ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(false);
    }

    // Actualizamos el estado cuando termine, sin importar cuánto tarde
    state = AuthState(
      user: _authManager.currentUser,
      driveApi: _authManager.driveApi,
      isLoading: false,
      lastResult: result,
    );
  }

  Future<void> login() async {
    state = AuthState(isLoading: true);
    try {
      await _authManager.loginFlow();

      if (_authManager.currentUser != null) {
        // Marcamos que ya no es un usuario que omitió
        await ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(false);

        // Estado de éxito total
        state = AuthState(
          user: _authManager.currentUser,
          driveApi: _authManager.driveApi,
          isLoading: false,
          lastResult:
              SilentLoginResult.success, // <--- IMPORTANTE: Actualizar esto
        );
      } else {
        // El usuario cerró la ventana de Google sin elegir cuenta
        state = AuthState(
          isLoading: false,
          lastResult: SilentLoginResult.noUser,
        );
      }
    } catch (e) {
      debugPrint("❌ Error en el login: $e");
      // Si falla el login manual, lo tratamos como error o expirado según el caso
      state = AuthState(
        isLoading: false,
        lastResult: SilentLoginResult.expired,
      );
    }
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);

    // 1. Limpiamos Google (Tokens, Client, etc.)
    await _authManager.logout();

    // 2. IMPORTANTE: Limpiamos el flag de 'skipped'
    // Si no haces esto, y el usuario alguna vez logueó,
    // al cerrar sesión podría quedarse bloqueado en WelcomePage
    // o saltar a Home erróneamente.
    await ref.read(skipedAuthProvider.notifier).clear();

    // 3. Reset total del estado
    state = AuthState(
      isLoading: false,
      user: null,
      driveApi: null,
      lastResult: SilentLoginResult.noUser,
    );

    debugPrint("Cerramos sesión y limpiamos rastro de 'skipped'.");
  }

  Future<void> skipLogin() async {
    // ❌ ELIMINA ESTA LÍNEA: state = AuthState(isLoading: true);

    try {
      final skipStorage = ref.read(skipedAuthProvider.notifier);
      await skipStorage.saveHasSkippedAuth(true);

      // ✅ Actualizamos el estado directamente a "No autenticado pero listo"
      state = AuthState(user: null, driveApi: null, isLoading: false);

      debugPrint("✅ Usuario decidió omitir. Transición directa a HomePage.");
    } catch (e) {
      debugPrint("❌ Error al guardar omitir: $e");
      // Solo si falla algo catastrófico nos aseguramos de quitar cualquier loading
      state = AuthState(isLoading: false);
    }
  }
}

// Cambié el import de legacy por el estándar de Riverpod
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthState {
  final GoogleSignInAccount? user;
  final DriveApi? driveApi;
  final bool isLoading;
  final SilentLoginResult? lastResult; // <--- Nuevo campo

  AuthState({
    this.user,
    this.driveApi,
    this.isLoading = false,
    this.lastResult,
  });

  bool get isAuthenticated => user != null && driveApi != null;
  bool get isSessionExpired => lastResult == SilentLoginResult.expired;
}
