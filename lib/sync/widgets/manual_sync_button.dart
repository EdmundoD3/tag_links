import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/sync/sync_notifier_provider.dart';

class ManualSyncButton extends ConsumerWidget {
  const ManualSyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final authState = ref.watch(authProvider);

    // Extraemos el estado de los datos de forma segura
    final state = syncState.value ?? SyncState();

    return IconButton(
      tooltip: _getTooltip(state, authState.isAuthenticated, ref),
      icon: _buildIcon(
        context,
        state: state,
        isAuth: authState.isAuthenticated,
        fixIntent: () => ref.read(syncProvider.notifier).synchronize(),
      ),
      onPressed: () async {
        // 1. Caso: No hay sesión iniciada
        if (!authState.isAuthenticated) {
          final bool? wantLogin = await _showLoginInvitation(context, ref);
          if (wantLogin == true) {
            await ref.read(authProvider.notifier).login();
          }
          return;
        }

        // Detectar si el estado de sincronización falló por credenciales
        final isAuthError =
            state.status == SyncStatus.error &&
            (state.lastError == "AUTH_401" ||
                state.lastError == "Inicia sesión de nuevo");

        if (isAuthError) {
          // Intentamos login para refrescar el token
          await ref.read(authProvider.notifier).login();
          // Una vez logueado, reintentamos la sincronización automáticamente
          ref.read(syncProvider.notifier).forceSynchronize();
          return;
        }

        if (state.status == SyncStatus.syncing) return;

        ref.read(syncProvider.notifier).forceSynchronize();
      },
    );
  }

  Widget _buildIcon(
    BuildContext context, {
    required SyncState state,
    required bool isAuth,
    required VoidCallback fixIntent,
  }) {
    if (!isAuth) {
      return const Icon(Icons.cloud_off, color: Colors.grey);
    }
    final theme = Theme.of(context);

    switch (state.status) {
      case SyncStatus.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        );

      case SyncStatus.error:
        return IconButton(
          icon: const Icon(Icons.sync_problem),
          onPressed: fixIntent,
          color: Colors.orangeAccent,
        );

      case SyncStatus.success:
        return const Icon(Icons.cloud_done, color: Colors.green);
      default:
        return Icon(Icons.sync_outlined, color: theme.iconTheme.color);
    }
  }

  String _getTooltip(SyncState state, bool isAuth, WidgetRef ref) {
    if (!isAuth)
      return ref.tr(
        TKeys.sync.loginSync,
        fallback: "Inicia sesión para sincronizar",
      );
    if (state.status == SyncStatus.error) {
      debugPrint("Error: ${state.lastError}");
      return ref.tr(TKeys.sync.errorSync, fallback: "Error al sincronizar");
    }
    if (state.status == SyncStatus.syncing)
      return ref.tr(
        TKeys.sync.driveSync,
        fallback: "Sincronizando con Drive...",
      );
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ref.tr(TKeys.actions.notNow, fallback: "Ahora no")),
          ),
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
