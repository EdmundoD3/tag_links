import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/sync/sync_notifier_provider.dart';

class ManualSyncButton extends ConsumerWidget {
  const ManualSyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    // Dentro del build del ManualSyncButton
    final authState = ref.watch(authProvider);

    return IconButton(
      // Si no está logueado, le ponemos un color grisáceo o un icono tachado
      icon: !authState.isAuthenticated
          ? const Icon(Icons.cloud_off, color: Colors.grey)
          : syncState.maybeWhen(
              data: (s) => s.status == SyncStatus.syncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              orElse: () => const Icon(Icons.sync),
            ),
      onPressed: !authState.isAuthenticated
          ? () {
              // _mostrarAvisoLogin(context); // Un mensaje que diga "¡Loguéate!"
            }
          : (syncState.value?.status == SyncStatus.syncing
                ? null
                : () => ref.read(syncProvider.notifier).forceSynchronize()),
    );
  }
}
