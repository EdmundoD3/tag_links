import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:tag_links/core/auth/skiped_auth_provider.dart';
import 'package:tag_links/core/google/auth_manager.dart';
import 'package:tag_links/repository/notes_repository.dart';

class AuthState {
  final GoogleSignInAccount? user;
  final DriveApi? driveApi;
  final bool isLoading;

  AuthState({this.user, this.driveApi, this.isLoading = false});

  // Ahora es más robusto verificar la autenticación
  bool get isAuthenticated => user != null && driveApi != null;
  static AuthState voidState() {
    return AuthState(isLoading: true);
  }
}

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
      final skipStorage = ref.read(skipedAuthProvider);
      final hasSkipped = skipStorage.getHasSkippedAuth();

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
      await _authManager.trySilentLogin().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
    } catch (e) {
      debugPrint("Error en init: $e");
    } finally {
      // ESTO GARANTIZA QUE EL LOADING SE QUITE SIEMPRE
      state = AuthState(
        user: _authManager.currentUser,
        driveApi: _authManager.driveApi,
        isLoading: false,
      );
    }
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

      // --- NUEVO: Si el login fue exitoso, ya no es un "skiped" user ---
      if (_authManager.currentUser != null) {
        await ref.read(skipedAuthProvider).saveHasSkippedAuth(false);
      }
      // -------------------------------------------------------------

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

  Future<void> skipLogin() async {
    // 1. Ponemos la app en estado de carga breve para dar feedback visual
    state = AuthState(isLoading: true);

    try {
      // 2. Obtenemos el storage y guardamos que el usuario decidió omitir
      final skipStorage = ref.read(skipedAuthProvider);
      await skipStorage.saveHasSkippedAuth(true);

      // 3. Actualizamos el estado final: No hay usuario, no hay Drive,
      // pero isLoading es false.
      state = AuthState(user: null, driveApi: null, isLoading: false);

      debugPrint("✅ Usuario decidió omitir el login de Google.");
    } catch (e) {
      debugPrint("❌ Error al guardar preferencia de omitir: $e");
      // En caso de error, quitamos el loading para no bloquear al usuario
      state = AuthState(isLoading: false);
    }
  }
}

// Cambié el import de legacy por el estándar de Riverpod
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
