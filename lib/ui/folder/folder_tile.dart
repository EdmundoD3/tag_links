import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/locate/app_lang.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/ui/form/folder_form_page.dart';
import 'package:tag_links/ui/menu/menu_container.dart';

class FolderTile extends ConsumerWidget {
  final List<ActionMenuItem> actionsItems;
  final Folder folder;
  final void Function() goFolder;
  final void Function() onDeleteFolder;
  final GlobalKey _tileKey = GlobalKey();

  FolderTile({super.key, required this.folder, required this.actionsItems, required this.onDeleteFolder, required this.goFolder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        return InkWell(
      key: _tileKey,
      onTap: () => goFolder(),
      onLongPress: () => _actionsMenu(context, ref),
      child: _FolderCard(folder: folder),
    );
  }
    void _actionsMenu(BuildContext context, WidgetRef ref) {
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
          label: t(ref, 'edit', fallback: 'Editar'),
          onTap: () => _editFolder(context),
        ),
        ActionMenuItem(
          icon: Icons.delete,
          label: t(ref, 'delete', fallback: 'Eliminar'),
          onTap: () => onDeleteFolder()
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
    final theme = Theme.of(context);
    return Card(
      elevation: 3, // La sombra que le da profundidad
      margin: const EdgeInsets.only(top: 16, left: 12, right: 12), // Margen exterior
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ), // Bordes redondeados
      color: theme.cardTheme.color,
      child: ListTile(
        leading: Icon(
          Icons.folder,
          color: Colors.deepPurpleAccent,
        ), // Un toque de color
        title: Text(
          folder.title,
          style: TextStyle(fontWeight: FontWeight.bold, color:theme.textTheme.titleMedium?.color),
        ),
        trailing: folder.isFavorite
            ? Icon(Icons.favorite, color: Colors.red, size: 20)
            : null,
      ),
    );
  }
}