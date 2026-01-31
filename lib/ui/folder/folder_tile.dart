import 'package:flutter/material.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/ui/menu/menu_container.dart';

class FolderTile extends StatelessWidget {
  final List<ActionMenuItem> actionsItems;
  final Folder folder;
  final void Function() goFolder;
  final void Function() onDeleteFolder;
  final GlobalKey _tileKey = GlobalKey();

  FolderTile({super.key, required this.folder, required this.actionsItems, required this.onDeleteFolder, required this.goFolder});

  @override
  Widget build(BuildContext context) {
        return InkWell(
      key: _tileKey,
      onTap: () => goFolder(),
      onLongPress: () => _actionsMenu(context),
      child: _FolderCard(folder: folder),
    );
  }
    void _actionsMenu(BuildContext context) {
    final box = _tileKey.currentContext!.findRenderObject() as RenderBox;

    final position = box.localToGlobal(Offset.zero);

    ActionMenu.showActionMenu(
      context: context,
      position: Offset(
        position.dx + box.size.width - 260, // alinear a la derecha
        position.dy - 8,
      ),
      items: [
        ActionMenuItem(
          icon: Icons.edit,
          label: 'Editar',
          onTap: () => _editFolder(context),
        ),
        ActionMenuItem(
          icon: Icons.delete,
          label: 'Eliminar',
          onTap: () =>  ConfirmDialog.deleteFolder(context, () async => onDeleteFolder())
        ),
        ...actionsItems,
      ],
    );
  }

  Future<void> _editFolder(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FolderFormPage(folder: folder)),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final Folder folder;

  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // La sombra que le da profundidad
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ), // Margen exterior
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ), // Bordes redondeados
      child: ListTile(
        leading: Icon(
          Icons.folder,
          color: Colors.deepPurple[400],
        ), // Un toque de color
        title: Text(
          folder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
    }
}