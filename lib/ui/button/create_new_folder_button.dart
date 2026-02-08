import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/locate/app_lang.dart';
import 'package:tag_links/ui/button/floating_button_base.dart';
import 'package:tag_links/ui/form/folder_form_page.dart';

class CreateNewFolderButton extends ConsumerWidget {
  final String? parentFolderId;
  final bool isRoot;

  const CreateNewFolderButton({
    super.key,
    this.parentFolderId,
    this.isRoot = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingButonBase(
      heroTag: t(ref, 'createFolder', fallback: 'Crear carpeta'),
      icon: Icons.create_new_folder,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              FolderFormPage(parentFolderId: parentFolderId, isRoot: isRoot),
        ),
      ),
    );
  }
}
