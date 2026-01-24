import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/state/pending_note_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/note/note_form_page.dart';

class BannerPendingNote extends ConsumerWidget {
  const BannerPendingNote({
    super.key,
    required this.toFolderId,
  });

  final String toFolderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(pendingNoteProvider);
    if (note == null) return const SizedBox.shrink();

    return MaterialBanner(
      content: const Text('Tienes una nota pendiente de almacenar'),
      actions: [
        // ───────── Almacenar directo
        TextButton(
          onPressed: () {
            ref
                .read(noteMoveProvider)
                .move(note: note, toFolderId: toFolderId);
          },
          child: const Text('Almacenar'),
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
          child: const Text('Editar y almacenar'),
        ),

        // ───────── Descartar
        TextButton(
          onPressed: () async {
            final confirm = await showConfirmDialog(
              context,
              title: 'No mover la nota',
              message: '¿Estás seguro de descartar la acción?',
            );

            if (confirm == true) {
              ref.read(pendingNoteProvider.notifier).clear();
            }
          },
          child: const Text('Descartar'),
        ),
      ],
    );
  }
}
