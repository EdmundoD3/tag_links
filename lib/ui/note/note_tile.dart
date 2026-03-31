import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/ui/container/bouncing_widget.dart';
import 'package:tag_links/ui/container/tile_container.dart';
import 'package:tag_links/ui/link/link_preview_widget.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/form/note_form_page.dart';
import 'package:tag_links/ui/text/expandable_decorated_text.dart';
import 'package:tag_links/ui/text/read_more_label.dart';
import 'package:tag_links/ui/utils/page_buil.dart';
import 'package:tag_links/utils/color_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteTile extends ConsumerStatefulWidget {
  final Note note;
  final List<ActionMenuItem> actionsItems;
  final void Function(Note note) onDeleteNote;
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
      //expandText
      onTap: () => setState(() => _isNoteExpanded = !_isNoteExpanded),
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

    ActionMenu.showActionMenu(
      context: context,
      position: Offset(
        widgetPosition.dx + renderBox.size.width - 260,
        position != null ? position.dy : widgetPosition.dy - 8,
      ),
      items: [
        if (widget.note.link != null)
          ActionMenuItem(
            icon: Icons.open_in_new,
            label: t(ref, 'openLink', fallback: 'Abrir enlace'),
            onTap: () => _openLink(
              context,
              notOpenLinkMsg: t(
                ref,
                'notOpenLink',
                fallback: 'No se encontró una app para abrir este enlace',
              ),
              errorOpenLinkMsg: t(
                ref,
                'errorOpenLink',
                fallback: 'URL no válida o mal formada',
              ),
            ),
          ),
        ActionMenuItem(
          icon: Icons.edit,
          label: t(ref, 'edit', fallback: 'Editar'),
          onTap: () => _editNote(context),
        ),
        ActionMenuItem(
          icon: Icons.copy,
          label: t(ref, 'copyText', fallback: 'Copiar'),
          onTap: () => _copyText(
            context,
            t(ref, 'copiedText', fallback: 'Texto copiado'),
          ),
        ),
        ActionMenuItem(
          icon: Icons.move_down_rounded,
          label: t(ref, 'moveDown', fallback: 'Mover'),
          onTap: () => widget.onMove(widget.note),
        ),
        ActionMenuItem(
          icon: Icons.delete,
          label: t(ref, 'delete', fallback: 'Eliminar'),
          onTap: () => widget.onDeleteNote(widget.note),
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
  final bool showReadMore;


  const _NoteTileCard({
    required this.note,
    required this.onShowMenu,
    required this.tileKey,
    required this.isExpanded,
    required this.onTap,
    required this.onLineCountCheck,
    required this.showReadMore,
  });
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
        child: IconButton(
          onPressed: () => onShowMenu(null),
          icon: const Icon(Icons.more_vert, size: 20),
          splashRadius: 20,
        ),
      ),
      child: TileContainer(
        cardColor: theme.cardColor,
        borderRadius: BorderRadius.circular(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleWidget(theme, note),
            _lineColorDecorator(note.color),
            ..._linkPreviewWidget(theme, note),
            const SizedBox(height: 10),
            ExpandableDecoratedText(
       text: note.content,
       isExpanded: isExpanded, // Le pasas el estado desde el padre
       onLineCountCheck: onLineCountCheck,
     ),if (showReadMore)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ReadMoreLabel(isExpanded: isExpanded),
            ),
            const SizedBox(height: 8),
            _footer(theme: theme),
          ],
        ),
      ),
    );
  }

  Widget _lineColorDecorator(String? color) {
    final lineColor = FolderColorUtils.resolveColor(color);
    return Divider(
      color: lineColor, // Color de la línea
      thickness: 1, // Grosor de la línea
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
      const SizedBox(height: 4),
      LinkPreviewWidget(preview: note.link!),
      const Divider(
        color: Colors.grey, // Color de la línea
        thickness: 1, // Grosor de la líneasa
        indent: 0, // Espacio vacío al inicio (izquierda)
        endIndent: 0, // Espacio vacío al final (derecha)
      ),
    ];
  }

  Widget _footer({required ThemeData theme}) {
    return Row(
      children: [
        Expanded(
          child: _miniTags(theme: theme, tags: note.tags),
        ),
        const SizedBox(width: 8),
        _dateWidget(theme: theme, date: note.updatedAt),
      ],
    );
  }

  Widget _dateWidget({required ThemeData theme, required DateTime date}) {
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
    String resultado = tags.map((tag) => '#${tag.name}').join(', ');

    return Text(
      resultado,
      style: theme.textTheme.labelMedium,
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
