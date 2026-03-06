import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/state/pending_folder_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';

class BannerPendingFolder extends ConsumerWidget {
  const BannerPendingFolder({super.key, required this.toParentId});

  final String? toParentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final folder = ref.watch(pendingFolderProvider);

    // 1. Si no hay carpeta seleccionada, no mostramos nada.
    if (folder == null) return const SizedBox.shrink();

    // 2. Verificamos si estamos en el mismo lugar (evitar mover a donde ya está).
    final isSameFolder = folder.id == toParentId;
    if (isSameFolder) return const SizedBox.shrink();

    // 3. Verificamos la "Lista Negra" (Hijos y descendientes).
    final forbiddenAsync = ref.watch(forbiddenDestinationsProvider);

    return forbiddenAsync.when(
      data: (forbiddenIds) {
        // Si el destino actual es un descendiente de la carpeta a mover... OCULTAR.
        if (forbiddenIds.contains(toParentId)) {
          return const SizedBox.shrink();
        }

        return MaterialBanner(
          elevation: 1,
          backgroundColor: theme.cardColor,
          content: Text(t(ref, 'alertMovePendingFolder', 
              fallback: 'Tienes una carpeta pendiente de mover'),
              style: TextStyle(color: theme.textTheme.labelSmall?.color) ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(folderMoveProvider).move(
                      folder: folder,
                      toParentId: toParentId,
                    );
              },
              child: Text(
                t(ref, 'store', fallback: 'Almacenar'),
                style: TextStyle(color: theme.textTheme.titleLarge?.color),
              ),
            ),
            TextButton(
              onPressed: () async {
                final confirm = await showConfirmDialog(
                  context,
                  title: t(ref, 'bannerNotMove', fallback: 'No mover'),
                  message: t(ref, 'discardAction', 
                      fallback: '¿Estás seguro de descartar la acción?'),
                );

                if (confirm == true) {
                  ref.read(pendingFolderProvider.notifier).clear();
                }
              },
              child: Text(
                t(ref, 'discard', fallback: 'Descartar'),
                style: TextStyle(color: theme.textTheme.titleLarge?.color),
              ),
            ),
          ],
        );
      },
      // Mientras carga la lista negra o si hay error, mejor no mostrar el banner por seguridad.
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}