import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/ui/note/build_notes_list.dart';

class NotesSection extends ConsumerStatefulWidget {
  final String? folderId;
  final String? highlightNoteId;

  const NotesSection({
    super.key,
    required this.folderId,
    this.highlightNoteId,
  });

  @override
  ConsumerState<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends ConsumerState<NotesSection> {
  final ScrollController _scrollController = ScrollController();

  AsyncNotifierProvider<NotesNotifier, List<Note>> get _notesProvider =>
      notesProvider(widget.folderId);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- scroll infinito ----------
  void _onScroll() {
    final position = _scrollController.position;
    final notesNotifier = ref.read(_notesProvider.notifier);

    if (position.pixels >= position.maxScrollExtent - 200 &&
        notesNotifier.hasMore &&
        !notesNotifier.isLoadingMore) {
      notesNotifier.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceProvider = widget.folderId != null
        ? _notesProvider
        : notesViewProvider;

    final notes = ref.watch(sourceProvider);
    final notifier = ref.read(_notesProvider.notifier);

    return BuildNotesList(
      notesAsync: notes,
      scrollController: _scrollController,
      isLoadingMore: notifier.isLoadingMore,
      onDeleteNote: (note) => notifier.deleteNote(note),
    );
  }
}