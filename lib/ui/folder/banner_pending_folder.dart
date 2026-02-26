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
    if (folder == null) return const SizedBox.shrink();

    return MaterialBanner(
      content: Text(t(ref, 'alertMovePendingFolder', fallback: 'Tienes una carpeta pendiente de mover')),
      actions: [
        TextButton(
          onPressed: () {
            ref
                .read(folderMoveProvider)
                .move(folder: folder, toParentId: toParentId);
          },
          child: Text(t(ref, 'store', fallback: 'Almacenar'), style: TextStyle(color: theme.textTheme.bodySmall?.color)),
        ),
        TextButton(
          onPressed: () async {
            final confirm = await showConfirmDialog(
              context,
              title: t(ref, 'bannerNotMove', fallback: 'No mover'),
              message: t(ref, 'discardAction', fallback: '¿Estás seguro de descartar la acción?'),
            );

            if (confirm == true) {
              ref.read(pendingFolderProvider.notifier).clear();
            }
          },
          child: Text(t(ref, 'discard', fallback: 'Descartar'), style: TextStyle(color: theme.textTheme.bodySmall?.color)),
        ),
      ],
    );
  }
}
