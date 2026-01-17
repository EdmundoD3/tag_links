import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/state/shared_media_provider.dart';
import 'package:tag_links/state/url_provider.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();

    _sub = ShareListener.stream.listen(_handleMedia);

    ShareListener.getInitial().then(_handleMedia);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _handleMedia(SharedMedia? media) {
    final mediaIsNull = media == null;
    final contentIsEmpty = media?.content?.trim().isEmpty ?? true;

    if (mediaIsNull || contentIsEmpty) {
      return;
    }
    final text = media.content!;
    _handleIncomingUrl(text);
  }

void _handleIncomingUrl(String text) {
  final notifier = ref.read(sharedNoteProvider.notifier);

  final urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
  final match = urlRegex.firstMatch(text);

  // 1. Crear nota base con todo el texto
  final note = Note.baseNote(content: text);

  // 2. Si hay URL, crear link mínimo
  if (match != null) {
    final url = match.group(0)!;

    note.link = LinkPreview.create(
      noteId: note.id,
      url: url,
    );
  }

  // 3. Guardar nota temporal
  notifier.set(note);
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
