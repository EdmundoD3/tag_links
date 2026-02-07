import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/state/pending_note_provider.dart';

void handleMedia(SharedMedia? media, WidgetRef ref) {
  final mediaIsNull = media == null;
  final contentIsEmpty = media?.content?.trim().isEmpty ?? true;

  if (mediaIsNull || contentIsEmpty) {
    return;
  }
  final text = media.content!;
  _handleIncomingUrl(text, ref);
}

void _handleIncomingUrl(String text, WidgetRef ref) {
  final notifier = ref.read(pendingNoteProvider.notifier);

  final urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
  final match = urlRegex.firstMatch(text);

  String content = text;
  if (match != null) {
    content = text.replaceFirst(match.group(0)!, '').trim();
  }

  // 1. Crear nota base con todo el texto
  final note = Note.baseNote(content: content);

  // 2. Si hay URL, crear link mínimo
  if (match != null) {
    final url = match.group(0)!;

    note.link = LinkPreview.create(noteId: note.id, url: url);
  }

  // 3. Guardar nota temporal
  notifier.set(note);
}
