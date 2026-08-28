import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/core/media_in_coming/pending_note_provider.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';

void handleMedia(String? text, WidgetRef ref) {

  if (text == null || text.trim().isEmpty) {
    return;
  }

  _handleIncomingUrl(text, ref);
}

void _handleIncomingUrl(String text, WidgetRef ref) async {

  final notifier = ref.read(pendingNoteProvider.notifier);

  final urlRegex = RegExp(
    r'(https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  final match = urlRegex.firstMatch(text);

  String url = "";
  String description = text;

  if (match != null) {
    url = match.group(0)!;

    description = text
        .replaceFirst(url, '')
        .trim();
  }

  final fileId = await ref
      .read(localSyncQueueRepositoryProvider)
      .getOrCreateAvailableFileId(TypeQueue.notes);

  final note = Note.baseNote(
    content: description,
    fileId: fileId,
  );

  if (url.isNotEmpty) {
    note.link = LinkPreview.create(
      noteId: note.id,
      url: url,
    );
  }

  notifier.set(
    note,
    TypeMove.newNote,
  );
}