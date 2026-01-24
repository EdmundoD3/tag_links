import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/state/pending_folder_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';

class BannerPendingFolder extends ConsumerWidget {
  const BannerPendingFolder({super.key, required this.toParentId});

  final String? toParentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(pendingFolderProvider);
    if (folder == null) return const SizedBox.shrink();

    return MaterialBanner(
      content: const Text('Tienes una carpeta pendiente de mover'),
      actions: [
        TextButton(
          onPressed: () {
            ref
                .read(folderMoveProvider)
                .move(folder: folder, toParentId: toParentId);
          },
          child: const Text('Almacenar'),
        ),
        TextButton(
          onPressed: () async {
            final confirm = await showConfirmDialog(
              context,
              title: 'No mover la carpeta',
              message: '¿Estás seguro de descartar la accion?',
            );

            if (confirm == true) {
              ref.read(pendingFolderProvider.notifier).clear();
            }
          },
          child: const Text('Descartar'),
        ),
      ],
    );
  }
}
