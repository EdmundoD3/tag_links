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
  
  // Regex un poco más flexible
  final urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
  final match = urlRegex.firstMatch(text);

  String url = "";
  String description = text;

  if (match != null) {
    url = match.group(0)!;
    // Removemos la URL del texto original para dejar solo el comentario del usuario
    description = text.replaceFirst(url, '').trim();
  }

  // Si el usuario compartió SOLO el link, la descripción queda vacía.
  // Podrías dejarla así o ponerle un placeholder.
  final note = Note.baseNote(content: description);

  if (url.isNotEmpty) {
    // Usamos el LinkPreview que ya tiene tu lógica de enriquecimiento
    note.link = LinkPreview.create(noteId: note.id, url: url);
  }

  // 🚀 IMPORTANTE: Esto debe disparar una reacción en la UI
  notifier.set(note, TypeMove.newNote);
}