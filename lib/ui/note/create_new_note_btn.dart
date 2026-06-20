import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/decorate_color/decorated_color_themes.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/sync/sync_fowder_handler.dart';
import 'package:tag_links/ui/form/note_form_page.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class CreateNewNoteButton extends ConsumerWidget {
  final String? folderId;
  final DecorateColor? decorateColor;
  const CreateNewNoteButton({super.key, required this.folderId, this.decorateColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return IconButton(
      style: theme.iconButtonTheme.style?.copyWith(iconSize:WidgetStateProperty.all(28)),
      icon: Icon(Icons.note_add, color: decorateColor?.light?? theme.colorScheme.onPrimary),
      tooltip: ref.tr(TKeys.ui.addNote, fallback: 'Add note'),
      onPressed: () async {
        // 1. Despachamos la tarea a segundo plano usando el contexto fresco del click
        unawaited(SyncFlowHandler.handleSilentSyncCheck(context, ref));
        // 2. Traemos el ID asíncrono de la base de datos local
        final fileId = await ref
            .read(localSyncQueueRepositoryProvider)
            .getOrCreateAvailableFileId(TypeQueue.notes);
        // 3. 🛡️ ¡Aduana de contexto! Verificamos que el usuario no haya cerrado la app
        // o navegado hacia atrás mientras se leía la DB local.
        if (!context.mounted) return;
        goPage(
          context: context,
          page: NoteFormPage(folderId: folderId, fileId: fileId),
        );
      },
    );
  }
}
