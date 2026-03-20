import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/state/pending_note_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/banners/banner_pending.dart';
import 'package:tag_links/ui/form/note_form_page.dart';

class BannerPendingNote extends ConsumerWidget {
  final Future<void> Function() onToggleView;
  final String? toFolderId;
  const BannerPendingNote({
    super.key,
    required this.toFolderId,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingNote = ref.watch(pendingNoteProvider);
    if (pendingNote == null) return const SizedBox.shrink();
    final note = pendingNote.note;

    return BannerPending(
      title: '''${t(
        ref,
        'bannerPendingNote',
        fallback: 'Tienes una nota pendiente de almacenar',
      )}: ${note.title}''',
      actions: [
        // ───────── Almacenar directo
        BannerOptionsTile(
          onTap: () {
            onToggleView();
            if (pendingNote.type == TypeMove.move) {
              ref
                  .read(noteMoveProvider)
                  .move(note: note, toFolderId: toFolderId);
            }
            if (pendingNote.type == TypeMove.newNote) {
              ref
                  .read(noteMoveProvider)
                  .save(note: note, toFolderId: toFolderId);
            }
          },
          title: t(ref, 'store', fallback: 'Almacenar'),
        ),

        // ───────── Editar y luego almacenar
        if (pendingNote.type == TypeMove.newNote)
          BannerOptionsTile(
            onTap: () {
              onToggleView();
              ref
                  .read(noteMoveProvider)
                  .save(note: note, toFolderId: toFolderId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteFormPage(
                    note: note,
                    folderId: toFolderId,
                    isPending: true,
                  ),
                ),
              );
            },
            title: t(ref, 'editAndStore', fallback: 'Editar y almacenar'),
          ),

        // ───────── Descartar
        BannerOptionsTile(
          onTap: () async {
            final confirm = await showConfirmDialog(
              context,
              title: t(ref, 'bannerNotMove', fallback: 'No mover la nota'),
              message: t(
                ref,
                'discardAction',
                fallback: '¿Estás seguro de descartar la acción?',
              ),
              ref: ref,
            );

            if (confirm == true) {
              ref.read(pendingNoteProvider.notifier).clear();
            }
          },
          title: t(ref, 'discard', fallback: 'Descartar'),
        ),
      ],
    );
  }
}
