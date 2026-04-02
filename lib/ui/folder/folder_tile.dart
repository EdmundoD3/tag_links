import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/core/locate/time/format_time.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/ui/container/tile_container.dart';
import 'package:tag_links/ui/form/folder_form_page.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/utils/page_buil.dart';
import 'package:tag_links/ui/container/bouncing_widget.dart'; // Asegúrate de que la ruta sea correcta

class FolderTile extends ConsumerStatefulWidget {
  final List<ActionMenuItem> actionsItems;
  final Folder folder;
  final void Function() goFolder;
  final void Function() onDeleteFolder;
  final void Function(Folder folder) onMove;

  const FolderTile({
    super.key,
    required this.folder,
    required this.actionsItems,
    required this.onDeleteFolder,
    required this.goFolder,
    required this.onMove,
  });

  @override
  ConsumerState<FolderTile> createState() => _FolderTileState();
}

class _FolderTileState extends ConsumerState<FolderTile> {
  final GlobalKey _tileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      key: _tileKey,
      onTap: widget.goFolder,
      onLongPressStart: (details) =>
          _actionsMenu(context, ref, details.globalPosition),
      // AGREGAMOS EL BOTÓN AQUÍ:
      trailing: Trailing(
        top: 12,
        right: 10,
        child: IconButton(
          onPressed: () => _actionsMenu(context, ref, null),
          icon: const Icon(
            Icons.more_vert,
            size: 22,
          ), // Un poco más grande para carpetas
          splashRadius: 20,
          color: Theme.of(context).hintColor,
        ),
      ),
      child: _FolderCard(
        folder: widget.folder,
        updatedAt: ref.fmt(widget.folder.updatedAt),
      ),
    );
  }

  void _actionsMenu(BuildContext context, WidgetRef ref, Offset? position) {
    final box = _tileKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final widgetPosition = box.localToGlobal(Offset.zero);

    ActionMenu.showActionMenu(
      context: context,
      position: Offset(
        widgetPosition.dx + box.size.width - 260,
        position != null
            ? position.dy
            : widgetPosition.dy + 10, // Ajuste leve si es desde el botón
      ),
      items: [
        ActionMenuItem(
          icon: Icons.edit,
          label: ref.tr(TKeys.actions.edit, fallback: 'Editar'),
          onTap: () => _editFolder(context),
        ),
        ActionMenuItem(
          icon: Icons.delete,
          label: ref.tr(TKeys.actions.delete, fallback: 'Eliminar'),
          onTap: () => widget.onDeleteFolder(),
        ),
        ActionMenuItem(
          icon: Icons.move_down_rounded,
          label: ref.tr(TKeys.actions.move, fallback: 'Mover'),
          onTap: () => widget.onMove(widget.folder),
        ),
        ...widget.actionsItems,
      ],
    );
  }

  Future<void> _editFolder(BuildContext context) {
    return goPage(
      context: context,
      page: FolderFormPage(
        folder: widget.folder,
        parentFolderId: widget.folder.parentId,
        fileId: widget.folder.fileId,
      ),
    );
  }
}

// El _FolderCard se mantiene casi igual, solo quitamos el Card para que el
// BouncingButton maneje el color de fondo sobre una superficie limpia si lo prefieres,
// pero dejaremos el Card por tu diseño de sombras.
class _FolderCard extends StatelessWidget {
  final Folder folder;
  final String updatedAt;

  const _FolderCard({required this.folder, required this.updatedAt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TileContainer(
      borderRadius: BorderRadius.circular(8),
      cardColor: theme.cardTheme.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder, color: theme.badgeTheme.textColor),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  // Agregamos padding a la derecha para que el texto no choque con el botón
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(
                    folder.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (folder.isFavorite)
                const Icon(Icons.favorite, color: Colors.red, size: 20),
              if (folder.isFavorite) const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 8),
          _footer(theme: theme),
        ],
      ),
    );
  }

  Widget _footer({required ThemeData theme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _miniTags(theme: theme, tags: folder.tags),
        ),
        const SizedBox(width: 8),
        _dateWidget(theme: theme, date: updatedAt),
      ],
    );
  }

  Widget _dateWidget({required ThemeData theme, required String date}) {
    return Text(
      date,
      style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
      textAlign: TextAlign.right,
    );
  }

  Widget _miniTags({required ThemeData theme, List<Tag> tags = const []}) {
    String resultado = tags.map((tag) => '#${tag.name}').join(' ');
    return Text(
      resultado,
      style: theme.textTheme.labelMedium,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
