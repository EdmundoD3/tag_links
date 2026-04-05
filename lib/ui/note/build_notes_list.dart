import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/state/pending_note_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/is_loading_indicators/shimmer_note_list.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/note/note_tile.dart';
import 'package:tag_links/ui/utils/empty_indicator.dart';

class BuildNotesList extends ConsumerWidget {
  final bool isLoadingMore;
  final Future<void> Function(Note note) onDeleteNote;
  final AsyncValue<List<Note>> notesAsync;
  final ScrollController scrollController;
  final List<ActionMenuItem>? actionsItems;
  final void Function(Note note)? goFolder;
  final GlobalKey Function(String id) getKey;

  const BuildNotesList({
    super.key,
    required this.notesAsync,
    required this.scrollController,
    this.actionsItems = const [],
    this.goFolder,
    required this.isLoadingMore,
    required this.onDeleteNote,
    required this.getKey,
  });

  @override
  Widget build(BuildContext context, ref) {
    return notesAsync.when(
      data: (notes) {
        if (notes.isEmpty) {
          return EmptyIndicator(
            title: ref.tr(TKeys.ui.emptyNotes, fallback: 'No hay notas'),
          );
        }

        return ListView.builder(
          controller: scrollController,
          // Aplicamos el +1 para el spinner al final
          itemCount: notes.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (_, i) {
            // Spinner al final de la lista
            if (i == notes.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final note = notes[i];
            return NoteTile(
              // Cambiamos GlobalKey por ValueKey si es posible
              key: ValueKey(note.id),
              note: note,
              onDeleteNote: () => onDeleteNote(note),
              onMove: (n) async {
                final isConfirm = await ConfirmDialog.moveNote(context, ref);
                if (isConfirm == true) {
                  ref.read(pendingNoteProvider.notifier).set(n, TypeMove.move);
                }
              },
              actionsItems: [
                if (actionsItems != null) ...actionsItems!,
                if (goFolder != null)
                  ActionMenuItem(
                    icon: Icons.drive_folder_upload,
                    label: ref.tr(TKeys.ui.goToFolder, fallback: 'Ir a la carpeta'),
                    onTap: () => goFolder!(note),
                  ),
              ],
            );
          },
        );
      },
      loading: () => const ShimmerNotesList(),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
