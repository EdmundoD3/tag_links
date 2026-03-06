import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/state/pending_note_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/form/note_form_page.dart';

class BannerPendingNote extends ConsumerWidget {
  const BannerPendingNote({super.key, required this.toFolderId});

  final String toFolderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(pendingNoteProvider);
    final theme = Theme.of(context);
    if (note == null) return const SizedBox.shrink();

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
            ref.read(noteMoveProvider).move(note: note, toFolderId: toFolderId);
          },
          child: Text(t(ref, 'store', fallback: 'Almacenar'),
          style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        ),

        // ───────── Editar y luego almacenar
        TextButton(
          onPressed: () {
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
