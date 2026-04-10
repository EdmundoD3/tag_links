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
    // 🎯 Usamos microtask para no interferir con la creación del Provider
    Future.microtask(() => initSilentLogin());
    return AuthState(isLoading: false);
  }

  Future<void> _updateStateWithNewAuth(
    GoogleSignInAccount user, {
    bool interactive = false,
  }) async {
    // Forzamos la obtención de headers frescos.
    // Si 'interactive' es true, el AuthManager debería forzar el refresco interno.
    final authHeaders = await _authManager.getHeaders(
      user,
      forcePrompt: interactive,
    );

    if (authHeaders == null) {
      throw DrivePermissionDeniedException();
    }

    final newClient = GoogleHttpClient(authHeaders);
    final newDriveApi = drive.DriveApi(newClient);

    state = AuthState(
      user: user,
      driveApi: newDriveApi,
      isLoading: false,
      lastResult: SilentLoginResult.success,
    );
  }

  /// Proceso centralizado para crear el DriveApi y actualizar el estado de un solo golpe
  Future<bool> initSilentLogin() async {
    final hasSkipped = ref.read(skipedAuthProvider);
    if (hasSkipped == true) {
      state = AuthState(
        user: null,
        driveApi: null,
        isLoading: false,
        lastResult: null,
      );
      return false;
    }

    state = AuthState(isLoading: true);

    try {
      final user = await _authManager.getSilentUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException("Google timeout"),
      );

      if (user == null) {
        state = AuthState(
          isLoading: false,
          lastResult: SilentLoginResult.noUser,
        );
        return false;
      }

      // 🎯 Refrescamos headers para evitar el error 401 inmediato
      await _updateStateWithNewAuth(user);

      await ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(false);
      return true;
    } catch (e) {
      debugPrint("⚠️ Error en silent login: $e");

      final isAuthErr =
          e.toString().contains("401") ||
          e.toString().contains("AUTH_401") ||
          e is DrivePermissionDeniedException;

      state = AuthState(
        isLoading: false,
        lastResult: isAuthErr
            ? SilentLoginResult.expired
            : _mapErrorToResult(e),
        // Mantenemos al usuario aunque esté expirado para poder intentar login(interactivo) después
        user: state.user,
      );
      return false;
    }
  }

  Future<bool> login() async {
    state = AuthState(isLoading: true);
    try {
      final user = await _authManager.getInteractiveUser();

      if (user == null) {
        state = AuthState(
          isLoading: false,
          lastResult: SilentLoginResult.noUser,
        );
        return false;
      }

      // forcePrompt: true asegura que se pidan los permisos/headers de nuevo
      await _updateStateWithNewAuth(user, interactive: true);
      await ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(false);
      return true;
    } catch (e) {
      debugPrint("❌ Error en Login Manual: $e");
      state = AuthState(isLoading: false, lastResult: SilentLoginResult.error);
      return false;
    }
  }

  Future<bool> attemptSessionRepair() async {
    if (state.isAuthenticated && state.lastResult == SilentLoginResult.success)
      return true;
    if (state.isLoading) return false;

    if (_isRepairingResult) {
      debugPrint("🔧 AuthNotifier: Intentando reparación...");

      final currentUser = state.user;
      try {
        if (currentUser != null) {
          // Intentamos refrescar headers del usuario actual
          await _updateStateWithNewAuth(currentUser);
          return true;
        } else {
          return await initSilentLogin();
        }
      } catch (e) {
        // Si falla la actualización del usuario actual, intentamos flujo completo
        return await initSilentLogin();
      }
    }
    return state.isAuthenticated;
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

  bool get _isRepairingResult =>
      state.lastResult == SilentLoginResult.timeout ||
      state.lastResult == SilentLoginResult.networkError ||
      state.lastResult == SilentLoginResult.error ||
      state.lastResult == SilentLoginResult.expired;

  SilentLoginResult _mapErrorToResult(Object e) {
    final err = e.toString().toLowerCase();
    if (err.contains('network') || err.contains('socket'))
      return SilentLoginResult.networkError;
    if (err.contains('timeout')) return SilentLoginResult.timeout;
    return SilentLoginResult.error;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
