import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/auth/skiped_auth_provider.dart';
import 'package:tag_links/core/google/models/auth_exeptions.dart';
import 'package:tag_links/core/google/auth_manager.dart';
import 'package:tag_links/core/google/models/auth_state_model.dart';
import 'package:tag_links/core/google/models/silent_login_result.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tag_links/core/google/google_http_client.dart';

class AuthNotifier extends Notifier<AuthState> {
  AuthManager get _authManager => ref.read(authManagerProvider);

  @override
  AuthState build() {
    // Iniciamos sesión en segundo plano al arrancar
    initSilentLogin();
    return AuthState(isLoading: false);
  }

  /// Proceso centralizado para crear el DriveApi y actualizar el estado de un solo golpe
  Future<void> _updateStateWithNewAuth(GoogleSignInAccount user, {bool interactive = false}) async {
    // Obtenemos los headers frescos del Manager
    final authHeaders = await _authManager.getHeaders(user, forcePrompt: interactive);
    
    if (authHeaders == null) {
      throw DrivePermissionDeniedException();
    }

    // Creamos el cliente y el API que vivirán en este estado
    final newClient = GoogleHttpClient(authHeaders);
    final newDriveApi = drive.DriveApi(newClient);

    // 🎯 ACTUALIZACIÓN ATÓMICA
    state = AuthState(
      user: user,
      driveApi: newDriveApi,
      isLoading: false,
      lastResult: SilentLoginResult.success,
    );
  }

  Future<void> initSilentLogin() async {
    final hasSkipped = ref.read(skipedAuthProvider);
    if (hasSkipped == true) {
      state = AuthState(user: null, driveApi: null, isLoading: false, lastResult: null);
      return;
    }

    state = AuthState(isLoading: true);

    try {
      final user = await _authManager.getSilentUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException("Google timeout"),
      );

      if (user == null) {
        state = AuthState(isLoading: false, lastResult: SilentLoginResult.noUser);
        return;
      }

      await _updateStateWithNewAuth(user);
      
      // Si tuvo éxito, nos aseguramos de que el flag de skip esté en false
      await ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(false);

    } catch (e) {
      debugPrint("⚠️ Error en silent login: $e");
      state = AuthState(
        isLoading: false, 
        lastResult: _mapErrorToResult(e),
      );
    }
  }

  Future<void> login() async {
    state = AuthState(isLoading: true);
    try {
      final user = await _authManager.getInteractiveUser();
      
      if (user == null) {
        state = AuthState(isLoading: false, lastResult: SilentLoginResult.noUser);
        return;
      }

      await _updateStateWithNewAuth(user, interactive: true);
      await ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(false);

    } on DrivePermissionDeniedException {
      state = AuthState(isLoading: false, lastResult: SilentLoginResult.expired);
    } catch (e) {
      debugPrint("❌ Error en Login Manual: $e");
      state = AuthState(isLoading: false, lastResult: SilentLoginResult.error);
    }
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);

    // 1. Limpiamos en Google
    await _authManager.signOut();

    // 2. Marcamos como omitido para que el Router nos mande a Welcome
    await ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(true);

    // 3. Reset total. El cliente HTTP viejo se perderá con el estado anterior.
    state = AuthState(
      isLoading: false,
      user: null,
      driveApi: null,
      lastResult: SilentLoginResult.noUser,
    );
  }

  Future<void> skipLogin() async {
    try {
      await ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(true);
      state = AuthState(user: null, driveApi: null, isLoading: false);
    } catch (e) {
      debugPrint("❌ Error al saltar login: $e");
      state = AuthState(isLoading: false);
    }
  }

  Future<bool> attemptSessionRepair() async {
    // Si ya hay API y no hay errores, no hacemos nada
    if (state.isAuthenticated && state.lastResult == SilentLoginResult.success) return true;
    
    if (state.isLoading) return false;

    // Solo reparamos si el error es de red, timeout o genérico
    if (_isRepairingResult) {
      debugPrint("🔧 AuthNotifier: Intentando reparación...");
      
      final currentUser = state.user;
      if (currentUser != null) {
        try {
          await _updateStateWithNewAuth(currentUser);
          return true;
        } catch (e) {
          // Si falla con el usuario actual, intentamos login silencioso completo
          await initSilentLogin();
        }
      } else {
        await initSilentLogin();
      }
    }

    return state.isAuthenticated;
  }

  bool get _isRepairingResult =>
      state.lastResult == SilentLoginResult.timeout ||
      state.lastResult == SilentLoginResult.networkError ||
      state.lastResult == SilentLoginResult.error ||
      state.lastResult == SilentLoginResult.expired;

  SilentLoginResult _mapErrorToResult(Object e) {
    final err = e.toString().toLowerCase();
    if (err.contains('network') || err.contains('socket')) return SilentLoginResult.networkError;
    if (err.contains('timeout')) return SilentLoginResult.timeout;
    return SilentLoginResult.error;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);