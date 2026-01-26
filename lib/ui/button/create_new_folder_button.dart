import 'package:flutter/material.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';

class CreateNewFolderButton extends StatelessWidget {
  final String? parentFolderId;
  final bool isRoot;

  const CreateNewFolderButton({
    super.key,
    this.parentFolderId,
    this.isRoot = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'addFolder',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FolderFormPage(
            parentFolderId: parentFolderId,
            isRoot: isRoot,
          ),
        ),
      ),
      child: const Icon(Icons.create_new_folder),
    );
  }
}
