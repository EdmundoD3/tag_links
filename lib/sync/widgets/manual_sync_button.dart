import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/google/models/auth_state_model.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/sync/last_sync_storage.dart';
import 'package:tag_links/sync/sync_fowder_handler.dart';
import 'package:tag_links/sync/sync_notifier_provider.dart';
import 'package:tag_links/ui/modals/text_dialog.dart';
import 'package:tag_links/ui/button/action_button.dart';

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

    // 1. Caso: No autenticado en el estado actual de la app
    if (!authState.isAuthenticated) {
      // 💾 Revisamos si existe algún historial de sincronización previo
      final lastSync = ref.read(lastSyncProvider);
      // o la condición que use tu provider para saber si es válido
      final bool hasPreviousAccount = lastSync.lastLoggedEmail != null;

      if (hasPreviousAccount) {
        debugPrint(
          "🔄 Usuario previo detectado. Intentando reconexión silenciosa por debajo...",
        );

        // Intentamos parchar la sesión sin molestar al usuario
        await SyncFlowHandler.handleSilentSyncCheck(context, ref);

        if (!context.mounted) return;

        // Si el login silencioso falló (el token murió por completo), escalamos al interactivo sin mostrar el diálogo de invitación
        if (!ref.read(authProvider).isAuthenticated) {
          debugPrint(
            "⚠️ Login silencioso insuficiente. Escalando a interactivo...",
          );
          await SyncFlowHandler.handleInteractiveLogin(context, ref);
          if (!context.mounted) return;
        }
      } else {
        // 🆕 Es un usuario completamente nuevo: Le mostramos la invitación formal
        final bool? wantLogin = await _showLoginInvitation(context, ref);
        if (!context.mounted) return;

        if (wantLogin == true) {
          await SyncFlowHandler.handleInteractiveLogin(context, ref);
          if (!context.mounted) return;
        }
      }

      // Si cualquiera de las dos rutas anteriores logró recuperar la sesión con éxito, forzamos sync
      if (ref.read(authProvider).isAuthenticated) {
        syncNotifier.forceSynchronize();
      }
      return;
    }

    // 2. Caso: Error 401 (El usuario figura como autenticado pero Drive rechaza el token)
    final isAuthError =
        state.status == SyncStatus.error &&
        (state.lastError?.contains("401") == true ||
            state.lastError == "AUTH_401");

    if (isAuthError) {
      debugPrint("🔧 Reparando sesión 401 desde botón manual...");

      await SyncFlowHandler.handleSilentSyncCheck(context, ref);
      if (!context.mounted) return;

      if (!ref.read(authProvider).isAuthenticated) {
        await SyncFlowHandler.handleInteractiveLogin(context, ref);
        if (!context.mounted) return;
      }

      if (ref.read(authProvider).isAuthenticated) {
        syncNotifier.forceSynchronize();
      }
      return;
    }

    // 3. Estado normal: Si ya está sincronizando, ignoramos clics dobles
    if (state.status == SyncStatus.syncing) return;

    // Si todo está sano, ejecutamos la sincronización manual limpia
    syncNotifier.forceSynchronize();
  }

  Widget _buildIcon(
    BuildContext context, {
    required SyncState state,
    required bool isAuth,
  }) {
    // 🔘 Estado Gris: No hay nube configurada
    if (!isAuth) return const Icon(Icons.cloud_off, color: Colors.grey);
    final accent = Theme.of(context).iconTheme.color;
    final highlight = Theme.of(context).textTheme.labelMedium?.color;

    switch (state.status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: highlight),
        );
      case SyncStatus.error:
        // 🟠 Estado Naranja: Hay un problema que requiere atención
        return const Icon(Icons.sync_problem, color: Colors.orangeAccent);
      case SyncStatus.success:
        // 🟢 Estado Verde: Todo al día
        return Icon(Icons.cloud_done, color: highlight);
      default:
        return Icon(Icons.sync_outlined, color: accent);
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
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: TextDialogTitle(
          title: ref.tr(
            TKeys.sync.backUpTitle,
            fallback: "Respaldo en la nube",
          ),
          fontSize: 18,
        ),
        content: TextDialogContent(
          text: ref.tr(
            TKeys.sync.backUpMessage,
            fallback:
                "Para mantener tus notas seguras y sincronizadas en todos tus dispositivos, necesitas iniciar sesión con Google Drive.",
          ),
        ),
        actions: [
          ActionTextButton(
            onPressed: () => Navigator.pop(context, false),
            label: ref.tr(TKeys.actions.notNow, fallback: "Ahora no"),
          ),
          ActionButtonFilled(
            onPressed: () => Navigator.pop(context, true),
            label: ref.tr(
              TKeys.auth.loginWithGoogle,
              fallback: "Iniciar sesión",
            ),
          ),
        ],
      ),
    );
  }
}
