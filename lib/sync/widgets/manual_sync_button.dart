import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/google/models/auth_state_model.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/sync/sync_notifier_provider.dart';

class ManualSyncButton extends ConsumerWidget {
  const ManualSyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final authState = ref.watch(authProvider);

    // ✅ Si syncState es AsyncLoading o similar, manejamos el fallback
    final state = syncState.value ?? SyncState();

    return IconButton(
      tooltip: _getTooltip(state, authState.isAuthenticated, ref),
      // Agregamos una opacidad ligera si no está autenticado para reforzar el "gris"
      icon: Opacity(
        opacity: authState.isAuthenticated ? 1.0 : 0.6,
        child: _buildIcon(
          context,
          state: state,
          isAuth: authState.isAuthenticated,
        ),
      ),
      onPressed: () async => _syncronizeController(
        authState: authState,
        context: context,
        ref: ref,
        state: state,
      ),
    );
  }

  Future<void> _syncronizeController({
    required WidgetRef ref,
    required BuildContext context,
    required AuthState authState,
    required SyncState state,
  }) async {
    final syncNotifier = ref.read(syncProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    // 1. Caso: Gris / No autenticado -> Invitación (El reparador manual de conexión)
    if (!authState.isAuthenticated) {
      final bool? wantLogin = await _showLoginInvitation(context, ref);
      if (wantLogin == true) {
        final success = await authNotifier.login();
        if (success) syncNotifier.forceSynchronize();
      }
      return;
    }

    // 2. Caso: Error 401 (El reparador manual de credenciales)
    final isAuthError =
        state.status == SyncStatus.error &&
        (state.lastError?.contains("401") == true ||
            state.lastError == "AUTH_401");

    if (isAuthError) {
      debugPrint("🔧 Reparando sesión...");
      bool success = await authNotifier.initSilentLogin();
      if (!success) success = await authNotifier.login();

      if (success) syncNotifier.forceSynchronize();
      return;
    }

    // 3. Estado normal
    if (state.status == SyncStatus.syncing) return;
    syncNotifier.forceSynchronize();
  }

  Widget _buildIcon(
    BuildContext context, {
    required SyncState state,
    required bool isAuth,
  }) {
    // 🔘 Estado Gris: No hay nube configurada
    if (!isAuth) return const Icon(Icons.cloud_off, color: Colors.grey);

    switch (state.status) {
      case SyncStatus.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
        );
      case SyncStatus.error:
        // 🟠 Estado Naranja: Hay un problema que requiere atención
        return const Icon(Icons.sync_problem, color: Colors.orangeAccent);
      case SyncStatus.success:
        // 🟢 Estado Verde: Todo al día
        return const Icon(Icons.cloud_done, color: Colors.green);
      default:
        return Icon(Icons.sync_outlined, color: Theme.of(context).iconTheme.color,);
    }
  }

  String _getTooltip(SyncState state, bool isAuth, WidgetRef ref) {
    if (!isAuth) {
      return ref.tr(
        TKeys.sync.loginSync,
        fallback: "Inicia sesión para sincronizar",
      );
    }
    if (state.status == SyncStatus.error) {
      debugPrint("Error: ${state.lastError}");
      return ref.tr(TKeys.sync.errorSync, fallback: "Error al sincronizar");
    }
    if (state.status == SyncStatus.syncing) {
      return ref.tr(
        TKeys.sync.driveSync,
        fallback: "Sincronizando con Drive...",
      );
    }
    return ref.tr(TKeys.sync.syncNow, fallback: "Sincronizar ahora");
  }

  Future<bool?> _showLoginInvitation(BuildContext context, WidgetRef ref) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          ref.tr(TKeys.sync.backUpTitle, fallback: "Respaldo en la nube"),
        ),
        content: Text(
          ref.tr(
            TKeys.sync.backUpMessage,
            fallback:
                "Para mantener tus notas seguras y sincronizadas en todos tus dispositivos, necesitas iniciar sesión con Google Drive.",
          ),
        ),
        actions: [
          // TODO corregir colores  para que no paresca que estan desactivados
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ref.tr(TKeys.actions.notNow, fallback: "Ahora no")),
          ),
          // TODO corregir colores  para que no paresca que estan desactivados
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              ref.tr(TKeys.auth.loginWithGoogle, fallback: "Iniciar sesión"),
            ),
          ),
        ],
      ),
    );
  }
}
