import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:tag_links/core/auth/skiped_auth_provider.dart';
import 'package:tag_links/core/google/auth_manager.dart';
import 'package:tag_links/repository/notes_repository.dart';

class AuthNotifier extends Notifier<AuthState> {
  // Instanciamos el manager que acabamos de pulir
  AuthManager get _authManager => ref.read(authManagerProvider);

  @override
  AuthState build() {
    // Usamos microtask para que el silent login ocurra justo DESPUÉS
    // de que el provider se haya registrado correctamente.
    Future.microtask(() => _initSilentLogin());

    return AuthState(isLoading: false);
  }

  Future<void> _initSilentLogin() async {
    try {
      final hasSkipped = ref.read(skipedAuthProvider);

      if (hasSkipped == true) {
        state = AuthState(user: null, driveApi: null, isLoading: false);
        return;
      }
      // verificamos que si no existe hasSkipped, sea de verdad la primera vez que un usuario usa la aplicacion
      if (hasSkipped == null) {
        final bool hasAnyData = await ref
            .read(notesRepositoryProvider)
            .hasAnyData();
        if (hasAnyData == false) {
          // IMPORTANTE: Actualizamos el estado antes de salir para quitar el loading
          state = AuthState(user: null, driveApi: null, isLoading: false);
          return;
        }
      }

      // Pon un timeout si sospechas de la red
      final result = await _authManager.trySilentLogin().timeout(
        const Duration(seconds: 5),
        onTimeout: () => SilentLoginResult.timeout,
      );

      state = AuthState(
        user: _authManager.currentUser,
        driveApi: _authManager.driveApi,
        isLoading: false,
        lastResult: result, // Guardamos el por qué falló
      );
    } catch (e) {
      state = AuthState(isLoading: false, lastResult: SilentLoginResult.noUser);
    }
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
    await _authManager.logout();
    // Limpiamos todo el estado
    state = AuthState(
      isLoading: false, 
      user: null, 
      driveApi: null, 
      lastResult: SilentLoginResult.noUser // <--- Resetear aquí
    );
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
