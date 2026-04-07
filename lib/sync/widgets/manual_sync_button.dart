import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
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
      tooltip: _getTooltip(state, authState.isAuthenticated),
      icon: _buildIcon(context, state, authState.isAuthenticated),
      onPressed: !authState.isAuthenticated || state.status == SyncStatus.syncing
          ? null // Deshabilitado si no hay auth o si ya está sincronizando
          : () => ref.read(syncProvider.notifier).forceSynchronize(),
    );
  }

  Widget _buildIcon(BuildContext context, SyncState state, bool isAuth) {
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
            // Usamos el color del tema para que se vea integrado
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        );
      
      case SyncStatus.error:
        // Un rojo suave o naranja para indicar que algo falló sin ser alarmista
        return const Icon(Icons.sync_problem, color: Colors.orangeAccent);
      
      case SyncStatus.success:
        // Verde temporal para indicar que terminó bien
        return const Icon(Icons.cloud_done, color: Colors.green);
      
      case SyncStatus.idle:
      default:
        // El estado normal. Podrías ponerle un color azul si quieres que resalte
        return Icon(Icons.sync_outlined, color:theme.iconTheme.color);
    }
  }

  String _getTooltip(SyncState state, bool isAuth) {
    if (!isAuth) return "Inicia sesión para sincronizar";
    if (state.status == SyncStatus.error) return "Error: ${state.lastError ?? 'Desconocido'}";
    if (state.status == SyncStatus.syncing) return "Sincronizando con Drive...";
    return "Sincronizar ahora";
  }
}