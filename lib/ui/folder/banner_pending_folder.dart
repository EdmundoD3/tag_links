import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/state/pending_folder_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/banners/banner_pending.dart';

class BannerPendingFolder extends ConsumerWidget {
  final Function() onToggleView;
  const BannerPendingFolder({super.key, required this.toParentId, required this.onToggleView});

  final String? toParentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        return BannerPending(
          title: t(ref, 'alertMovePendingFolder', 
              fallback: 'Tienes una carpeta pendiente de mover'),
          actions: [
            BannerOptionsTile(
              onTap: () {
                onToggleView();
                ref.read(folderMoveProvider).move(
                      folder: folder,
                      toParentId: toParentId,
                    );
              },
              title: 
                t(ref, 'store', fallback: 'Almacenar'),
            ),
            BannerOptionsTile(
              onTap: () async {
                onToggleView();
                final confirm = await showConfirmDialog(
                  context,
                  title: t(ref, 'bannerNotMove', fallback: 'No mover'),
                  message: t(ref, 'discardAction', 
                      fallback: '¿Estás seguro de descartar la acción?'),
                      ref: ref,
                );

                if (confirm == true) {
                  ref.read(pendingFolderProvider.notifier).clear();
                }
              },
              title: 
                t(ref, 'discard', fallback: 'Descartar'),
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