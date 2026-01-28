import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/note/note_tile.dart';
import 'package:tag_links/ui/utils/empty_indicator.dart';

class BuildNotesList extends StatelessWidget {
  final NotesNotifier notifier;
  final AsyncValue<List<Note>> notesAsync;
  final ScrollController scrollController;
  final List<ActionMenuItem>? actionsItems;
  final void Function(Note note)? goFolder;

  const BuildNotesList({
    super.key,
    required this.notifier,
    required this.notesAsync,
    required this.scrollController,
    this.actionsItems = const [],
    this.goFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return EmptyIndicator(title: 'No hay notas');
          }

          return Stack(
            children: [
              if (notifier.isLoadingMore)
                const Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ListView.builder(
                controller: scrollController,
                itemCount: notes.length,
                itemBuilder: (_, i) => NoteTile(
                  note: notes[i],
                  onDeleteNote: (id) async {
                    try {
                      await notifier.deleteNote(id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nota eliminada')),
                      );
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al eliminar')),
                      );
                    }
                  },
                  actionsItems: [
                    if (actionsItems != null) ...actionsItems!,
                    if (goFolder != null)
                      ActionMenuItem(
                        icon: Icons.drive_folder_upload,
                        label: 'ir a la carpeta',
                        onTap: () => goFolder!(notes[i]),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
