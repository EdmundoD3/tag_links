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
import 'package:tag_links/sync/last_sync_storage.dart';

class AuthNotifier extends Notifier<AuthState> {
  AuthManager get _authManager => ref.read(authManagerProvider);

  @override
  AuthState build() {
    return AuthState(isLoading: false);
  }

  Future<void> _updateStateWithNewAuth(
    GoogleSignInAccount user, {
    bool interactive = false,
    bool ignorarConflicto =
        false, // Permite saltarse la aduana si el usuario ya aceptó
  }) async {
    // 🛡️ ADUANA DE CORREOS: Verificamos si hay conflicto con SharedPreferences
    if (!ignorarConflicto) {
      final syncInfo = ref.read(lastSyncProvider);
      final emailViejo = syncInfo.lastLoggedEmail;
      final emailNuevo = user.email;

      if (emailViejo != null && emailViejo != emailNuevo) {
        // Frenamos el flujo y lanzamos la alerta hacia el catch
        throw AccountConflictException(
          emailViejo: emailViejo,
          emailNuevo: emailNuevo,
          userIntruso: user,
        );
      }
    }

    final authHeaders = await _authManager.getHeaders(
      user,
      forcePrompt: interactive,
    );

    if (authHeaders == null) {
      throw DrivePermissionDeniedException();
    }

    final newClient = GoogleHttpClient(authHeaders);
    final newDriveApi = drive.DriveApi(newClient);

    // Si todo sale bien y no hubo conflicto (o se ignoró), guardamos/actualizamos el correo actual
    ref
        .read(lastSyncProvider.notifier)
        .update(
          email: user.email,
          lastPulledAt: DateTime.now().millisecondsSinceEpoch,
        );

    state = AuthState(
      user: user,
      driveApi: newDriveApi,
      isLoading: false,
      lastResult: SilentLoginResult.success,
    );
  }

  /// Proceso centralizado para crear el DriveApi y actualizar el estado de un solo golpe
  Future<bool> initSilentLogin() async {
    if (state.isAuthenticated) {
      return true;
    }

    if (state.isLoading) {
      return false;
    }
    final hasSkipped = ref.read(skipedAuthProvider);
    if (hasSkipped == true || hasSkipped == null) {
      state = AuthState(
        user: null,
        driveApi: null,
        isLoading: false,
        lastResult: null,
      );
      return false;
    }

    state = state.copyWith(isLoading: true);

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

      await _updateStateWithNewAuth(user);
      await ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(false);
      return true;
    } catch (e) {
      debugPrint("⚠️ Error en silent login: $e");

      // Si en el inicio silencioso hay conflicto de cuenta, cerramos sesión de forma segura
      if (e is AccountConflictException) {
        debugPrint(
          "🚫 Conflicto detectado en segundo plano. Abortando sesión intrusa.",
        );
        await logout();
        return false;
      }

      final isAuthErr =
          e.toString().contains("401") ||
          e.toString().contains("AUTH_401") ||
          e is DrivePermissionDeniedException;
      state = AuthState(
        isLoading: false,
        lastResult: isAuthErr
            ? SilentLoginResult.expired
            : _mapErrorToResult(e),
        user: state.user,
      );
      return false;
    }
  }

  Future<bool> login() async {
    if (state.isAuthenticated) {
      return true;
    }

    if (state.isLoading) {
      return false;
    }
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authManager.getInteractiveUser();
      if (user == null) {
        state = AuthState(
          isLoading: false,
          lastResult: SilentLoginResult.noUser,
        );
        return false;
      }
      await _updateStateWithNewAuth(user, interactive: true);
      await ref.read(skipedAuthProvider.notifier).saveHasSkippedAuth(false);
      return true;
    } catch (e) {
      // 🎯 AQUÍ CAPTURAMOS EL CONFLICTO EN EL LOGIN MANUAL
      if (e is AccountConflictException) {
        state = AuthState(
          isLoading: false,
          user: e
              .userIntruso, // Guardamos temporalmente el usuario para poder usarlo si deciden fusionar
          lastResult: SilentLoginResult
              .error, // O una propiedad personalizada si la tienes en tu enum
        );
        // Re-lanzamos el error para que la vista (.catchError o try/catch en el botón) abra el Diálogo
        rethrow;
      }

      debugPrint("AutNotifier: ❌ Error en Login Manual: $e");
      state = AuthState(isLoading: false, lastResult: SilentLoginResult.error);
      return false;
    }
  }

  Future<bool> attemptSessionRepair() async {
    if (state.isAuthenticated &&
        state.lastResult == SilentLoginResult.success) {
      return true;
    }
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
    state = state.copyWith(isLoading: true);

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

  /// Método público para cuando el usuario presione "SÍ, FUSIONAR" en tu diálogo
  Future<void> forzarFusionDeCuenta(GoogleSignInAccount user) async {
    state = state.copyWith(isLoading: true);
    try {
      await _updateStateWithNewAuth(
        user,
        ignorarConflicto: true,
        interactive: true,
      );
    } catch (e) {
      state = AuthState(isLoading: false, lastResult: SilentLoginResult.error);
    }
  }

  bool get _isRepairingResult =>
      state.lastResult == SilentLoginResult.timeout ||
      state.lastResult == SilentLoginResult.networkError ||
      state.lastResult == SilentLoginResult.error ||
      state.lastResult == SilentLoginResult.expired;

  SilentLoginResult _mapErrorToResult(Object e) {
    final err = e.toString().toLowerCase();
    if (err.contains('network') || err.contains('socket')) {
      return SilentLoginResult.networkError;
    }
    if (err.contains('timeout')) return SilentLoginResult.timeout;
    return SilentLoginResult.error;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
