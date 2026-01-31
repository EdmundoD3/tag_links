import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/note/note_tile.dart';
import 'package:tag_links/ui/utils/empty_indicator.dart';

class BuildNotesList extends StatelessWidget {
  final bool isLoadingMore;
  final Future<void> Function(String id) onDeleteNote;
  final AsyncValue<List<Note>> notesAsync;
  final ScrollController scrollController;
  final List<ActionMenuItem>? actionsItems;
  final void Function(Note note)? goFolder;

  const BuildNotesList({
    super.key,
    required this.notesAsync,
    required this.scrollController,
    this.actionsItems = const [],
    this.goFolder, required this.isLoadingMore, required this.onDeleteNote,
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
              if (isLoadingMore)
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
                    await onDeleteNote(id);
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
