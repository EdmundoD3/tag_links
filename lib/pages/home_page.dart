import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/paginate_provider.dart';
import 'package:tag_links/state/search_query_provider.dart';
import 'package:tag_links/state/shared_media_provider.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/banners/banner_pending.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/ui/folder/folder_tile.dart';
import 'package:tag_links/ui/search/search_menu.dart';
import 'package:tag_links/ui/tags/select_tags_container.dart';
import '../state/folders_provider.dart';
import '../models/folder.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasPendingSharedNotes = ref.watch(hasPendingSharedNoteProvider);
    final query = ref.watch(searchQueryProvider);
    final pagination = ref.watch(paginationProvider);

    final foldersAsync = ref.watch(folderSearchProvider((query, pagination)));

    return Scaffold(
      appBar: AppBar(
        title: hasPendingSharedNotes
            ? const Text('Selecciona donde almacenar la nota')
            : const Text('Folders'),
      ),
      floatingActionButton: _createNewFolderBtn(context),
      body: Column(
        children: [
          _bannerFolderHasPendingSharedNotes(context, ref),
          _searchBar(ref),
          _selectedIncludeTags(ref),
          _buildFolders(foldersAsync),
        ],
      ),
    );
  }

  void _onChangeText(WidgetRef ref, String text) {
    ref.read(searchQueryProvider.notifier).setText(text);
    ref.read(tagSearchTextProvider.notifier).state = text;
  }

  void _onChangePage(WidgetRef ref, int page) {
    ref.read(paginationProvider.notifier).state = ref
        .read(paginationProvider)
        .copyWith(page: page);
  }

  Widget _buildFolders(AsyncValue<List<Folder>> foldersAsync) {
    return foldersAsync.when(
      data: (folders) => ListView.builder(
              itemCount: folders.length,
              itemBuilder: (_, i) => FolderTile(folder: folders[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _searchBar(WidgetRef ref) {
    return SearchTags(
      onChangeText: (String text) => _onChangeText(ref, text),
      onTagSelected: (Tag tag) {
        ref.read(searchQueryProvider.notifier).addTag(tag);
      },
      queryText: ref.watch(searchQueryProvider).text,
      tagsSuggestion: ref.watch(tagsProvider),
    );
  }

  Widget _selectedIncludeTags(WidgetRef ref) {
    return SelectedTagsContainer(
      tags: ref.watch(searchQueryProvider).includeTags,
      onDeleted: (Tag tag) {
        ref.read(searchQueryProvider.notifier).removeTag(tag);
      },
    );
  }

  Widget _createNewFolderBtn(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _createNewFolder(context);
      },
      child: const Icon(Icons.add),
    );
  }

  Future<void> _createNewFolder(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FolderFormPage()),
    );
  }

  Widget _bannerFolderHasPendingSharedNotes(
    BuildContext context,
    WidgetRef ref,
  ) {
    return BannerPending(
      text: 'Elige una carpeta donde se guardará la nota compartida',
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
