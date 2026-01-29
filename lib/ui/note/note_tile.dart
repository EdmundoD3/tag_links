import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/link/link_preview_widget.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/note/note_form_page.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      key: _tileKey,
      // onTap: () => _openNote(context),
      onLongPress: () => _actionsMenu(context),
      child: _NoteTileCard(note: note),
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
        if (note.link != null)
          ActionMenuItem(
            icon: Icons.open_in_new,
            label: 'Abrir enlace',
            onTap: () => _openLink(context),
          ),
        ActionMenuItem(
          icon: Icons.edit,
          label: 'Editar',
          onTap: () => _editNote(context),
        ),
        ActionMenuItem(
          icon: Icons.copy,
          label: 'Copiar',
          onTap: () => _copyText(context),
        ),
        ActionMenuItem(
          icon: Icons.delete,
          label: 'Eliminar',
          onTap: () => _deleteNote(context),
        ),
        // const ActionMenuItem(icon: Icons.share, label: 'Compartir'),
        ...actionsItems,
      ],
    );
  }

  // functions
  void _copyText(BuildContext context) {
    final text = note.copyText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Texto copiado')));
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
  Future<void> _deleteNote(BuildContext context) async {
    final isDelete = await showConfirmDialog(
      context,
      title: "Eliminar nota",
      message: "¿Estás seguro de eliminar la nota?",
    );
    if (isDelete != true) return;

    if (!context.mounted) return;
    onDeleteNote(note.id);
  }

  Future<void> _openLink(BuildContext context) async {
    final link = note.link;
    if (link == null) return;

    final uri = Uri.parse(link.url);

    if (!await canLaunchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                const SizedBox(height: 4),
                // Preview
                _linkPreviewWidget(theme, note),
                Text(note.content),
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 2)),
        ],
      ),
      child: child,
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
        if (note.isFavorite)
          const Icon(Icons.star, color: Colors.amber, size: 18),
      ],
    );
  }

  Widget _linkPreviewWidget(ThemeData theme, Note note) {
    if (note.link == null) return const SizedBox.shrink();
    return LinkPreviewWidget(preview: note.link!);
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
