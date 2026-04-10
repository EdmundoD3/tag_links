import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/ui/button/floating_button_base.dart';
import 'package:tag_links/ui/form/note_form_page.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class CreateNewNoteButton extends ConsumerWidget {
  final String? folderId;
  const CreateNewNoteButton({super.key, required this.folderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(Icons.note_add, color: theme.iconTheme.color),
      tooltip: ref.tr(TKeys.ui.addNote, fallback: 'Add note'),
      onPressed: () async {
        final fileId = await ref
            .read(localSyncQueueRepositoryProvider)
            .getOrCreateAvailableFileId(TypeQueue.notes);
        if (context.mounted) {
          goPage(
            context: context,
            page: NoteFormPage(folderId: folderId, fileId: fileId),
          );
        }
      },
    );
  }
}
