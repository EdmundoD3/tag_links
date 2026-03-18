import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/ui/button/floating_button_base.dart';
import 'package:tag_links/ui/form/note_form_page.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class CreateNewNoteButton extends ConsumerWidget {
  final String? folderId;
  const CreateNewNoteButton({super.key, required this.folderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingButtonBase(
      heroTag: t(ref, 'fabAddNote', fallback: 'Add note'),
      icon: Icons.note_add,
      onPressed: () => goPage(
        context: context,
        page: NoteFormPage(folderId: folderId),
      ),
    );
  }
}