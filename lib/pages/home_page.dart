import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/is_folder_provider.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/state/search_query_provider.dart';
import 'package:tag_links/state/pending_note_provider.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/app_bar/app_bar_folder.dart';
import 'package:tag_links/ui/banners/banner_pending.dart';
import 'package:tag_links/ui/folder/banner_pending_folder.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/ui/folder/folder_tile.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/note/note_tile.dart';
import 'package:tag_links/ui/search/search_bar.dart';
import 'package:tag_links/ui/tags/tag_selected_container.dart';
import 'package:tag_links/utils/note_helpers.dart';
import '../state/folders_provider.dart';
import '../models/folder.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 120) {
        final isFolder = ref.read(isFolderProvider);

        if (isFolder) {
          ref.read(foldersProvider(null).notifier).loadMore();
        } else {
          ref.read(notesProvider(null).notifier).loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPendingNotes = ref.watch(hasPendingNoteProvider);
    final foldersAsync = ref.watch(foldersViewProvider);
    final bool isFolder = ref.watch(isFolderProvider);

    final notesAsync = ref.watch(
      notesViewProvider,
    ); //en este caso como valor inicial o sea cuando no hay parametros de busqueda
    //que empieze con las notas favoritas

    return Scaffold(
      appBar: AppBarFolder(),
      floatingActionButton: _createNewFolderBtn(context),
      body: Column(
        children: [
          if (hasPendingNotes) _bannerHasPendingNotes(context, ref),
          BannerPendingFolder(toParentId: null),

          _searchBar(ref, isFolder),
          _selectedIncludeTags(ref),
          isFolder ? _buildFolders(foldersAsync) : _buildNotes(notesAsync),
        ],
      ),
    );
  }

  void _onChangeText(WidgetRef ref, String text) {
    ref.read(searchQueryProvider.notifier).setText(text);
    ref.read(tagSearchTextProvider.notifier).state = text;

    // 🔁 fuerza rebuild limpio
    ref.invalidate(foldersProvider(null));
    ref.invalidate(notesProvider(null));
  }

  Widget _buildFolders(AsyncValue<List<Folder>> foldersAsync) {
    final notifier = ref.read(foldersProvider(null).notifier);

    return Expanded(
      child: foldersAsync.when(
        data: (folders) {
          if (folders.isEmpty) {
            return const Center(child: Text('No hay carpetas'));
          }

          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount: folders.length,
                itemBuilder: (_, i) => FolderTile(folder: folders[i]),
              ),

              if (notifier.isLoadingMore)
                const Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  /// 📝 Lista de notas
  Widget _buildNotes(AsyncValue<List<Note>> notesAsync) {
    final notifier = ref.read(notesProvider(null).notifier);

    return Expanded(
      child: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay notas'),
            );
          }

          return Stack(
            children: [
              if (notifier.isLoadingMore)
                const Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ListView.builder(
                controller: _scrollController,
                itemCount: notes.length,
                itemBuilder: (_, i) => NoteTile(
                  note: notes[i],
                  actionsItems: [
                    ActionMenuItem(
                      icon: Icons.drive_folder_upload,
                      label: 'ir a la carpeta',
                      onTap: () => NoteHelpers.goFolder(context, ref, notes[i]),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _searchBar(WidgetRef ref, bool isFolder) {
    return SearchListBar(
      iconLeftBtn: IconButton(
        onPressed: () {
          ref.read(isFolderProvider.notifier).state = !isFolder;

          ref.invalidate(foldersProvider(null));
          ref.invalidate(notesProvider(null));
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isFolder
              ? const Icon(Icons.note, key: ValueKey('note'))
              : const Icon(Icons.folder_open, key: ValueKey('folder')),
        ),
      ),
      onChangeText: (String text) => _onChangeText(ref, text),
      onTagSelected: (Tag tag) {
        ref.read(searchQueryProvider.notifier).addTag(tag);
      },
      queryText: ref.watch(searchQueryProvider).text,
      tagsSuggestion: ref.watch(tagsProvider),
    );
  }

  Widget _selectedIncludeTags(WidgetRef ref) {
    return TagsSelectedContainer(
      tags: ref.watch(searchQueryProvider).includeTags,
      onDeleted: (Tag tag) {
        ref.read(searchQueryProvider.notifier).removeTag(tag);
      },
    );
  }

  Widget _createNewFolderBtn(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'addFolder',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FolderFormPage(parentFolderId: null, isRoot: true,),
        ),
      ),
      child: const Icon(Icons.create_new_folder),
    );
  }

  //las notas no pueden estar en la carpeta raiz, por eso aqui solo se permite descartar la nota
  Widget _bannerHasPendingNotes(BuildContext context, WidgetRef ref) {
    return BannerPending(
      text: 'Elige una carpeta donde almacenar la nota',
      onClose: () async {
        final confirm = await showConfirmDialog(
          context,
          title: 'No almacenar la nota',
          message: '¿Estás seguro de descartar la nota?',
        );

        if (confirm == true) {
          ref.read(pendingNoteProvider.notifier).clear();
        }
      },
    );
  }
}
