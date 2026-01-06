import 'package:flutter/material.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/ui/note/note_form_page.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  const NoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: note.link?.url.isNotEmpty == true ? Text(note.link!.url) : null,
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          _editNote(context, note);
        },
      ),
    );
  }

  Future<void> _editNote(BuildContext context, Note note) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormPage(note: note, folderId: note.folderId),
      ),
    );
  }
}
