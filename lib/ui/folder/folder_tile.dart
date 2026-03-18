import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/ui/form/folder_form_page.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class FolderTile extends ConsumerWidget {
  final List<ActionMenuItem> actionsItems;
  final Folder folder;
  final void Function() goFolder;
  final void Function() onDeleteFolder;
  final void Function(Folder folder) onMove;
  final GlobalKey _tileKey = GlobalKey();

  FolderTile({
    super.key,
    required this.folder,
    required this.actionsItems,
    required this.onDeleteFolder,
    required this.goFolder,
    required this.onMove,
  });

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
          onTap: () => onDeleteFolder(),
        ),
        ActionMenuItem(
          icon: Icons.move_down_rounded,
          label: t(ref, 'moveDown', fallback: 'mover'),
          onTap: () => onMove(folder)),
        ...actionsItems,
      ],
    );
  }

  Future<void> _editFolder(BuildContext context) {
    //conservamos el parentId
    return goPage(context: context, page: FolderFormPage(folder: folder, parentFolderId: folder.parentId));
  }
}

class _FolderCard extends StatelessWidget {
  final Folder folder;

  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.white.withValues(alpha: 0.5),
      margin: const EdgeInsets.only(top: 10, left: 12, right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Espaciado interno uniforme
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PARTE SUPERIOR: Icono, Título y Favorito
            Row(
              children: [
                Icon(
                  Icons.folder,
                  color: theme.badgeTheme.textColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    folder.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ),
                if (folder.isFavorite)
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            _footer(theme: theme),
          ],
        ),
      ),
    );
  }

  Widget _footer({required ThemeData theme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end, // Alinea la fecha abajo si los tags crecen
      children: [
        Expanded(
          child: _miniTags(theme: theme, tags: folder.tags),
        ),
        const SizedBox(width: 8),
        _dateWidget(theme: theme, date: folder.updatedAt),
      ],
    );
  }

  Widget _dateWidget({
    required ThemeData theme,
    required DateTime date,
  }) {
    return Text(
      _formatDate(date),
      style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
      textAlign: TextAlign.right,
    );
  }

  String _formatDate(DateTime date) {
    String horas = date.hour.toString().padLeft(2, '0');
    String minutos = date.minute.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day/$month/$year | $horas:$minutos';
  }

  Widget _miniTags({required ThemeData theme, List<Tag> tags = const []}) {
    String resultado = tags.map((tag) => '#${tag.name}').join(' ');

    return Text(
      resultado,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.primaryColor.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

