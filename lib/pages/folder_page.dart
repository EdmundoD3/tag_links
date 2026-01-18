import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/state/shared_media_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/banners/banner_pending.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/ui/folder/folder_tile.dart';
import 'package:tag_links/ui/note/note_form_page.dart';
import 'package:tag_links/ui/note/note_tile.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FolderPage extends ConsumerStatefulWidget {
  final Folder folder;
  final Note? highlightNote;
  final PaginatedByDate? paginated;

  const FolderPage({
    super.key,
    required this.folder,
    this.highlightNote,
    this.paginated,
  });

  @override
  ConsumerState<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends ConsumerState<FolderPage> {
  final ScrollController _scrollController = ScrollController();
  bool _didScrollToHighlight = false;

  AsyncNotifierProvider<NotesNotifier, List<Note>> get _notesProvider =>
      notesProvider(widget.folder.id);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
  final position = _scrollController.position;
  final notifier = ref.read(_notesProvider.notifier);

  if (position.pixels >= position.maxScrollExtent - 200 &&
      notifier.hasMore &&
      !notifier.isLoadingMore) {
    notifier.loadMore();
  }
});

  }

  @override
  Widget build(BuildContext context) {
    final subFolders = ref.watch(foldersProvider(widget.folder.id));
    final notes = ref.watch(_notesProvider);
    final preferenceAsync = ref.watch(
      folderPreferenceProvider(widget.folder.id),
    );

    final hasPendingSharedNotes = ref.watch(hasPendingSharedNoteProvider);

    final sharedNote = ref.watch(sharedNoteProvider);

    return preferenceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (preference) {
        final showFolders = preference == FolderDefaultView.folders;

        if (!showFolders && widget.highlightNote != null) {
          _scrollToHighlightedNote(notes);
        }

        return Scaffold(
          appBar: _appBar(context, ref, showFolders, preference),
          floatingActionButton: _buildFab(context, showFolders, sharedNote),
          body: Column(
            children: [
              if (hasPendingSharedNotes)
                _bannerHasPendingSharedNotes(context, ref),

              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      controller: _scrollController,
                      children: showFolders
                          ? _foldersList(subFolders)
                          : _buildNotes(notes),
                    ),

                    // 👇 loader flotante
                    _loadMoreIndicator(notes),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

Widget _loadMoreIndicator(AsyncValue<List<Note>> notes) {
  return notes.when(
    data: (_) {
      final notifier = ref.read(_notesProvider.notifier);

      if (!notifier.isLoadingMore) {
        return const SizedBox.shrink();
      }

      return const Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Center(child: CircularProgressIndicator()),
      );
    },
    loading: () => const SizedBox.shrink(),
    error: (_, __) => const SizedBox.shrink(),
  );
}


  /// 🎯 Scroll a la nota resaltada (solo una vez)
void _scrollToHighlightedNote(AsyncValue<List<Note>> notesAsync) {
  if (_didScrollToHighlight) return;

  notesAsync.whenData((notes) {
    final index = notes.indexWhere(
      (n) => n.id == widget.highlightNote?.id,
    );

    if (index == -1) return;

    _didScrollToHighlight = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _scrollController.animateTo(
        index * 72.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  });
}


  PreferredSizeWidget _appBar(
    BuildContext context,
    WidgetRef ref,
    bool showFolders,
    FolderDefaultView preference,
  ) {
    return AppBar(
      title: Text(widget.folder.title),
      actions: [
        IconButton(
          onPressed: () => _toggleView(ref, preference),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: showFolders
                ? const Icon(Icons.note, key: ValueKey('note'))
                : const Icon(Icons.folder_open, key: ValueKey('folder')),
          ),
        ),
      ],
    );
  }

  /// 🔁 Cambiar vista y guardar preferencia
  Future<void> _toggleView(WidgetRef ref, FolderDefaultView current) async {
    final repo = ref.read(folderRepositoryProvider);
    final newView = current == FolderDefaultView.folders
        ? FolderDefaultView.notes
        : FolderDefaultView.folders;

    await repo.savePreference(widget.folder.id, newView);
    ref.invalidate(folderPreferenceProvider(widget.folder.id));
  }

  /// 📂 Lista de carpetas
  List<Widget> _foldersList(AsyncValue<List<Folder>> subFolders) {
    return subFolders.when(
      data: (folders) {
        if (folders.isEmpty) {
          return [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay carpetas'),
            ),
          ];
        }

        return folders.map((f) => FolderTile(folder: f)).toList();
      },
      loading: () => const [Center(child: CircularProgressIndicator())],
      error: (err, _) => [Center(child: Text('Error: $err'))],
    );
  }

  /// 📝 Lista de notas
  List<Widget> _buildNotes(AsyncValue<List<Note>> notes) {
    return notes.when(
      data: (items) {
        if (items.isEmpty) {
          return [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay notas'),
            ),
          ];
        }
        return items.map((n) => NoteTile(note: n)).toList();
      },
      loading: () => const [Center(child: CircularProgressIndicator())],
      error: (err, _) => [Center(child: Text('Error: $err'))],
    );
  }

  /// ➕ FAB dinámico
  Widget _buildFab(BuildContext context, bool showFolders, Note? sharedNote) {
    return showFolders
        ? _fabAddFolder(context)
        : _fabAddNote(context, sharedNote);
  }

  Widget _fabAddFolder(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'addFolder',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FolderFormPage(parentFolderId: widget.folder.id),
        ),
      ),
      child: const Icon(Icons.create_new_folder),
    );
  }

  Widget _fabAddNote(BuildContext context, Note? sharedNote) {
    return FloatingActionButton(
      heroTag: 'addNote',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              NoteFormPage(note: sharedNote, folderId: widget.folder.id),
        ),
      ),
      child: const Icon(Icons.note_add),
    );
  }

  // 🔔 Banners
  Widget _bannerHasPendingSharedNotes(BuildContext context, WidgetRef ref) {
    return BannerPending(
      text:
          'Tienes una nueva nota compartida. Puedes almacenarla aquí, elige o crea una carpeta donde se guardará la nota compartida',
      onClose: () async {
        final confirm = await showConfirmDialog(
          context,
          title: 'No almacenar la nueva nota',
          message: '¿Estás seguro de descartar la nueva nota?',
        );

        if (confirm == true) {
          ref.read(sharedNoteProvider.notifier).clear();
        }
      },
    );
  }
}
