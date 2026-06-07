import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/sync/sync_fowder_handler.dart';
import 'package:tag_links/ui/form/folder_form_page.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class CreateNewFolderButton extends ConsumerWidget {
  final String? parentFolderId;

  const CreateNewFolderButton({super.key, required this.parentFolderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(Icons.create_new_folder, color: theme.iconTheme.color),
      tooltip: ref.tr(TKeys.ui.createFolder, fallback: 'Crear carpeta'),
      onPressed: () async {
        // 1. Despachamos la tarea a segundo plano usando el contexto fresco del click
        unawaited(SyncFlowHandler.handleSilentSyncCheck(context, ref));
        // 2. Traemos el ID asíncrono de la base de datos local
        final fileId = await ref
            .read(localSyncQueueRepositoryProvider)
            .getOrCreateAvailableFileId(TypeQueue.folders);
        debugPrint('CreateNewFolderButton.onPressed fileId: $fileId');
        // 3. 🛡️ ¡Aduana de contexto! Verificamos que el usuario no haya cerrado la app
        // o navegado hacia atrás mientras se leía la DB local.
        if (!context.mounted) return;
        goPage(
          context: context,
          page: FolderFormPage(parentFolderId: parentFolderId, fileId: fileId),
        );
      },
    );
  }
}
