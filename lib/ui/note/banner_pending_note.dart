import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/core/media_in_coming/pending_note_provider.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/sync/sync_notifier_provider.dart';
import 'package:tag_links/ui/modals/confirm_dialog.dart';
import 'package:tag_links/ui/banners/banner_pending.dart';
import 'package:tag_links/ui/form/note_form_page.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class BannerPendingNote extends ConsumerWidget {
  final Future<void> Function() onToggleView;
  final String? toFolderId;
  final TypeNoteMove pendingNote;
  const BannerPendingNote({
    super.key,
    required this.toFolderId,
    required this.onToggleView,
    required this.pendingNote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = pendingNote.note;
    
    final title =
        '${ref.tr(TKeys.alerts.pendingNote, fallback: 'Tienes una nota pendiente de almacenar')}: ${note.title}';

    return BannerPending(
      title: title,
      actions: [
        // ───────── Almacenar directo
        BannerOptionsTile(
          onTap: () async {
            onToggleView();
            if (pendingNote.type == TypeMove.move) {
              await ref
                  .read(noteMoveProvider)
                  .move(note: note, toFolderId: toFolderId);
            }
            if (pendingNote.type == TypeMove.newNote) {
              await ref
                  .read(noteMoveProvider)
                  .save(note: note, toFolderId: toFolderId);
            }
            unawaited(ref.read(syncProvider.notifier).forceSynchronize());
          },
          title: ref.tr(TKeys.actions.store, fallback: 'Almacenar'),
        ),

        // ───────── Editar y luego almacenar
        if (pendingNote.type == TypeMove.newNote)
          BannerOptionsTile(
            onTap: () async {
              onToggleView();
              await ref
                  .read(noteMoveProvider)
                  .save(note: note, toFolderId: toFolderId);
              final fileId = await ref
                  .read(localSyncQueueRepositoryProvider)
                  .getOrCreateAvailableFileId(TypeQueue.notes);
              if (context.mounted) {
                goPage(
                  context: context,
                  page: NoteFormPage(
                    note: note,
                    folderId: toFolderId,
                    isPending: true,
                    fileId: fileId,
                  ),
                );
              }
            },
            title: ref.tr(
              TKeys.actions.editAndStore,
              fallback: 'Editar y almacenar',
            ),
          ),

        // ───────── Descartar
        BannerOptionsTile(
          onTap: () async {
            final confirm = await ConfirmDialog.discardPendingNote(context: context, ref: ref);

            if (confirm == true) {
              ref.read(pendingNoteProvider.notifier).clear();
            }
          },
          title: ref.tr(TKeys.actions.discard, fallback: 'Descartar'),
        ),
      ],
    );
  }
}
