import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/locate/app_lang.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/ui/link/link_preview_widget.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/form/note_form_page.dart';
import 'package:tag_links/ui/text/decorated_text.dart';
import 'package:tag_links/utils/color_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteTile extends ConsumerWidget {
  final Note note;
  final List<ActionMenuItem> actionsItems;
  final void Function(String id) onDeleteNote;
  final GlobalKey _tileKey = GlobalKey();

  NoteTile({
    super.key,
    required this.note,
    this.actionsItems = const [],
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      key: _tileKey,
      // onTap: () => _openNote(context),
      onLongPress: () => _actionsMenu(context, ref),
      child: _NoteTileCard(note: note),
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
        if (note.link != null)
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
          icon: Icons.delete,
          label: t(ref, 'delete', fallback: 'Eliminar'),
          onTap: () => onDeleteNote(note.id),
        ),
        ...actionsItems,
      ],
    );
  }

  // functions
  void _copyText(BuildContext context, String okMessage) {
    final text = note.copyText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(okMessage)));
  }

  void _editNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormPage(note: note, folderId: note.folderId),
      ),
    );
  }

  // helpers
  Future<void> _openLink(
    BuildContext context, {
    required String notOpenLinkMsg,
    required String errorOpenLinkMsg,
  }) async {
    final link = note.link;
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

  const _NoteTileCard({required this.note});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _container(
      theme: theme,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + estrella
                _titleWidget(theme, note),
                _lineColorDecorator(note.color),
                ..._linkPreviewWidget(theme, note),
                const SizedBox(height: 10),
                DecoratedText(text: note.content),
                // Fecha
                const SizedBox(height: 6),
                _dateWidget(theme, note.createdAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _container({required ThemeData theme, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 12, right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 1)),
        ],
      ),
      child: child,
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
        if (note.isFavorite) Icon(Icons.star, color: Colors.amber, size: 20),
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

  Widget _dateWidget(ThemeData theme, DateTime date) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        _formatDate(date),
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
    );
  }

  String _formatDate(DateTime date) {
    String horas = date.hour.toString().padLeft(2, '0');
    String minutos = date.minute.toString().padLeft(2, '0');
    return '$horas:$minutos';
  }
}
