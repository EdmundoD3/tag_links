import 'package:flutter/material.dart';
import 'package:tag_links/ui/button/floating_button_base.dart';
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
    return FloatingButonBase(
      heroTag: 'addFolder',
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
