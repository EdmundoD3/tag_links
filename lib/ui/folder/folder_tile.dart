import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/decorate_color/decorated_color_themes.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/core/locate/time/format_time.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/ui/container/tile_container.dart';
import 'package:tag_links/ui/form/folder_form_page.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/text/mini_tags_footer.dart';
import 'package:tag_links/ui/utils/page_buil.dart';
import 'package:tag_links/ui/container/bouncing_widget.dart';

import '../button/more_vert_button.dart'; // Asegúrate de que la ruta sea correcta

class FolderTile extends ConsumerStatefulWidget {
  final List<ActionMenuItem> actionsItems;
  final Folder folder;
  final void Function() goFolder;
  final void Function() onDeleteFolder;
  final void Function() onMove;

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
        child: MoreVertButton(
          onPressed: () => _actionsMenu(context, ref, null),
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
          onTap: () => widget.onMove(),
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

  DecorateColor? get _decorateColor => DecorateColor.fromCode(folder.color);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TileContainer(
      borderRadius: BorderRadius.circular(8),
      cardColor: theme.cardTheme.copyWith(color: _decorateColor?.light).color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _folderIcon(theme),
              const SizedBox(width: 12),
              _title(theme),
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
  Widget _folderIcon(ThemeData theme){
    return Icon(Icons.folder, color: theme.badgeTheme.copyWith(textColor: _decorateColor?.strong.withAlpha(220)).textColor);
  }

  Widget _title(ThemeData theme) {
    return Expanded(
      child: Padding(
        // Agregamos padding a la derecha para que el texto no choque con el botón
        padding: const EdgeInsets.only(right: 30),
        child: Text(
          folder.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: _decorateColor?.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _footer({required ThemeData theme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: MiniTagsFooter(tags: folder.tags,color: _decorateColor?.acent,),
        ),
        const SizedBox(width: 8),
        _dateWidget(theme: theme, date: updatedAt),
      ],
    );
  }

  Widget _dateWidget({required ThemeData theme, required String date}) {
    return Text(
      date,
      style: theme.textTheme.labelSmall?.copyWith(color: _decorateColor?.text?? theme.hintColor),
      textAlign: TextAlign.right,
    );
  }
}
