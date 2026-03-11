import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/state/pending_note_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/form/note_form_page.dart';

class BannerPendingNote extends ConsumerWidget {
  final Future<void> Function() onToggleView;
  const BannerPendingNote({super.key, required this.toFolderId, required this.onToggleView});

  final String toFolderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final pendingNote = ref.watch(pendingNoteProvider);
    final theme = Theme.of(context);
    if (pendingNote == null) return const SizedBox.shrink();
    final note = pendingNote.note;
    return MaterialBanner(
      backgroundColor: theme.cardColor,
      content: Text(
        t(
          ref,
          'bannerPendingNote',
          fallback: 'Tienes una nota pendiente de almacenar',
        ),
        style: TextStyle(color: theme.textTheme.labelSmall?.color),
      ),
      actions: [
        // ───────── Almacenar directo
        TextButton(
          onPressed: () {
            onToggleView();
            if(pendingNote.type == TypeMove.move) {
              ref.read(noteMoveProvider).move(note: note, toFolderId: toFolderId);
            }
            if(pendingNote.type == TypeMove.newNote) {
              ref.read(noteMoveProvider).save(note: note, toFolderId: toFolderId);
            }
          },
          child: Text(t(ref, 'store', fallback: 'Almacenar'),
          style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        ),

        // ───────── Editar y luego almacenar
        if(pendingNote.type == TypeMove.newNote)
        TextButton(
          onPressed: () {
            onToggleView();
            ref.read(noteMoveProvider).save(note: note, toFolderId: toFolderId);
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
          child: Text(t(ref, 'editAndStore', fallback: 'Editar y almacenar'),
          style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        ),

        // ───────── Descartar
        TextButton(
          onPressed: () async {
            final confirm = await showConfirmDialog(
              context,
              title: t(ref, 'bannerNotMove', fallback: 'No mover la nota'),
              message: t(
                ref,
                'discardAction',
                fallback: '¿Estás seguro de descartar la acción?',
              ),
            );

            if (confirm == true) {
              ref.read(pendingNoteProvider.notifier).clear();
            }
          },
          child: Text(t(ref, 'discard', fallback: 'Descartar'),
          style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        ),
      ],
    );
  }
}
