import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/core/locate/time/format_time.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/repository/link_preview_repository.dart';
import 'package:tag_links/ui/container/bouncing_widget.dart';
import 'package:tag_links/ui/container/tile_container.dart';
import 'package:tag_links/ui/link/link_preview_widget.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/form/note_form_page.dart';
import 'package:tag_links/ui/text/visual_expandable_text.dart';
import 'package:tag_links/ui/utils/page_buil.dart';
import 'package:tag_links/utils/decorated_color_themes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import '../button/more_vert_button.dart';

class NoteTile extends ConsumerStatefulWidget {
  final Note note;
  final List<ActionMenuItem> actionsItems;
  final void Function() onDeleteNote;
  final void Function(Note note) onMove;

  const NoteTile({
    super.key,
    required this.note,
    required this.onMove,
    this.actionsItems = const [],
    required this.onDeleteNote,
  });

  @override
  ConsumerState<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends ConsumerState<NoteTile> {
  // AQUÍ ES DONDE DEBE VIVIR LA LLAVE
  final GlobalKey _tileKey = GlobalKey();
  bool _isNoteExpanded = false;
  bool _showReadMore = false;

  @override
  Widget build(BuildContext context) {
    return _NoteTileCard(
      // IMPORTANTE: Pasamos la llave aquí para que el RenderBox sea el de la tarjeta
      tileKey: _tileKey,
      note: widget.note,
      updatedAt: ref.fmt(widget.note.updatedAt),
      //expandText
      onTap: () {
        FocusScope.of(context).unfocus();
        // si no esta expandido, lo hacemos expandido
        if (!_isNoteExpanded) {
          setState(() => _isNoteExpanded = !_isNoteExpanded);
        }
      },
      isExpanded: _isNoteExpanded,
      onLineCountCheck: (exceeds) {
        if (_showReadMore != exceeds) {
          setState(() => _showReadMore = exceeds);
        }
      },
      showReadMore: _showReadMore,
      // menu
      onShowMenu: (position) =>
          _actionsMenu(context: context, ref: ref, position: position),

      clearLinkPreview: () async {
        final preview = widget.note.link;
        if(preview != null) {
          ref
          .read(linkPreviewRepositoryProvider)
          .invalidatePreviewImage(preview);
          
        }},
    );
  }

  void _actionsMenu({
    required BuildContext context,
    required WidgetRef ref,
    Offset? position,
  }) {
    final renderBox = _tileKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final widgetPosition = renderBox.localToGlobal(Offset.zero);
    final double screenWidth = MediaQuery.of(context).size.width;
    const double menuWidth = 260.0;
    double desiredX = widgetPosition.dx + renderBox.size.width - menuWidth;
    double safeX = math.max(
      10.0,
      math.min(desiredX, screenWidth - menuWidth - 10.0),
    );

    ActionMenu.showActionMenu(
      context: context,
      position: Offset(
        safeX,
        position != null ? position.dy : widgetPosition.dy - 8,
      ),
      items: [
        if (widget.note.link != null)
          ActionMenuItem(
            icon: Icons.open_in_new,
            label: ref.tr(TKeys.actions.openLink, fallback: 'Abrir enlace'),
            onTap: () => _openLink(
              context,
              notOpenLinkMsg: ref.tr(
                TKeys.errors.notOpenLink,
                fallback: 'No se encontró una app para abrir este enlace',
              ),
              errorOpenLinkMsg: ref.tr(
                TKeys.errors.openLink,
                fallback: 'URL no válida o mal formada',
              ),
            ),
          ),
        ActionMenuItem(
          icon: Icons.edit,
          label: ref.tr(TKeys.actions.edit, fallback: 'Editar'),
          onTap: () => _editNote(context),
        ),
        ActionMenuItem(
          icon: Icons.copy,
          label: ref.tr(TKeys.actions.copy, fallback: 'Copiar'),
          onTap: () => _copyText(
            context,
            ref.tr(TKeys.actions.copiedSuccess, fallback: 'Texto copiado'),
          ),
        ),
        ActionMenuItem(
          icon: Icons.move_down_rounded,
          label: ref.tr(TKeys.actions.move, fallback: 'Mover'),
          onTap: () => widget.onMove(widget.note),
        ),
        ActionMenuItem(
          icon: Icons.delete,
          label: ref.tr(TKeys.actions.delete, fallback: 'Eliminar'),
          onTap: () => widget.onDeleteNote(),
        ),

        ...widget.actionsItems,
      ],
    );
  }

  // functions
  void _copyText(BuildContext context, String okMessage) {
    final text = widget.note.copyText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(okMessage)));
  }

  void _editNote(BuildContext context) {
    goPage(
      context: context,
      page: NoteFormPage(
        note: widget.note,
        folderId: widget.note.folderId,
        fileId: widget.note.fileId,
      ),
    );
  }

  // helpers
  Future<void> _openLink(
    BuildContext context, {
    required String notOpenLinkMsg,
    required String errorOpenLinkMsg,
  }) async {
    final link = widget.note.link;
    if (link == null || link.url.isEmpty) return;

    // 1. Limpiar la URL (quitar espacios en blanco accidentales)
    final String urlString = link.url.trim();
    final Uri uri = Uri.parse(urlString);

    try {
      // 2. Intentar lanzar la URL directamente
      // LaunchMode.externalApplication es la clave para que aparezca el "menú" de apps
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showError(context, notOpenLinkMsg);
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, errorOpenLinkMsg);
      }
    }
  }

  // Helper rápido para errores
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NoteTileCard extends StatelessWidget {
  final Note note;
  final GlobalKey tileKey;
  final void Function(Offset?) onShowMenu;
  final bool isExpanded;
  final void Function() onTap;
  final Function(bool)? onLineCountCheck;
  final Future<void> Function()? clearLinkPreview;
  final bool showReadMore;
  final String updatedAt;

  const _NoteTileCard({
    required this.note,
    required this.onShowMenu,
    required this.tileKey,
    required this.isExpanded,
    required this.onTap,
    required this.onLineCountCheck,
    required this.showReadMore,
    required this.updatedAt,
    required this.clearLinkPreview,
  });
  DecorateColor? get _decorateColor => DecorateColor.fromCode(note.color);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BouncingButton(
      key: tileKey, // Asociamos la GlobalKey al contenedor que rebota
      onTap: onTap,
      onLongPressStart: (details) => onShowMenu(details.globalPosition),
      trailing: Trailing(
        top: 12,
        right: 10,
        child: MoreVertButton(onPressed: () => onShowMenu(null)),
      ),
      child: TileContainer(
        cardColor: _decorateColor?.light ?? theme.cardColor,
        borderRadius: BorderRadius.circular(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleWidget(theme, note),
            _lineColorDecorator(),
            const SizedBox(height: 6),
            ..._linkPreviewWidget(theme, note),
            const SizedBox(height: 10),
            VisualExpandableText(
              text: note.content,
              isExpanded: isExpanded,
              decorateColor: _decorateColor,
            ),
            // Ya no necesitas el "if (showReadMore)" porque el widget visual
            // se encarga de mostrar la flecha solo cuando no está expandido.
            const SizedBox(height: 8),
            _footer(theme: theme),
          ],
        ),
      ),
    );
  }

  Container _lineColorDecorator() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _decorateColor?.strong ?? Colors.black87,
            (_decorateColor?.strong ?? Colors.black87).withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _titleWidget(ThemeData theme, Note note) {
    return Row(
      // Alinea el ícono verticalmente al centro del texto
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            note.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _decorateColor?.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (note.isFavorite) ...[
          const SizedBox(width: 8), // Espacio de separación entre texto e ícono
          const Icon(Icons.favorite, color: Colors.red, size: 20),
          const SizedBox(width: 20), // Espacio de separación entre ícono y Menu
        ],
      ],
    );
  }

  List<Widget> _linkPreviewWidget(ThemeData theme, Note note) {
    if (note.link == null) return [];
    return [
      LinkPreviewWidget(
        preview: note.link!,
        clearLinkPreview: clearLinkPreview,
      ),
      const SizedBox(height: 6),
      _lineColorDecorator(),
    ];
  }

  Widget _footer({required ThemeData theme}) {
    return Row(
      children: [
        Expanded(
          child: _miniTags(theme: theme, tags: note.tags),
        ),
        const SizedBox(width: 8),
        _dateWidget(theme: theme, date: updatedAt),
      ],
    );
  }

  Widget _dateWidget({required ThemeData theme, required String date}) {
    return Text(
      date,
      style: theme.textTheme.labelSmall?.copyWith(
        color: _decorateColor?.strong,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _miniTags({required ThemeData theme, List<Tag> tags = const []}) {
    String resultado = tags.map((tag) => '#${tag.title}').join(', ');

    return Text(
      resultado,
      style: theme.textTheme.labelMedium?.copyWith(
        color: _decorateColor?.strong,
      ),
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
