import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/small_banner.dart';
import 'package:tag_links/core/debug/go_debug_page_buton.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/state/folder_preference_provider.dart';
import 'package:tag_links/sync/widgets/manual_sync_button.dart';
import 'package:tag_links/ui/app_bar/app_bar_folder.dart';
import 'package:tag_links/ui/button/bottom_switch_folder_note.dart';
import 'package:tag_links/ui/button/create_new_folder_button.dart';
import 'package:tag_links/ui/button/go_settings_button.dart';
import 'package:tag_links/ui/folder/banner_pending_folder.dart';
import 'package:tag_links/ui/folder/build_folders_section.dart';
import 'package:tag_links/ui/is_loading_indicators/scaffold_loading.dart';
import 'package:tag_links/ui/note/banner_pending_note.dart';
import 'package:tag_links/ui/note/build_notes_section.dart';
import 'package:tag_links/ui/note/create_new_note_btn.dart';
import 'package:tag_links/ui/search/root_search_section.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class HomePage extends ConsumerWidget {
  final Folder? folder;
  final String? highlightNoteId;

  final PaginatedByDate? paginated;

  const HomePage({
    super.key,
    required this.folder,
    this.paginated,
    this.highlightNoteId,
  });

  AsyncNotifierProvider<FolderPreferenceNotifier, FolderDefaultView>
  get _foldersPreferenceProvider => folderPreferenceProvider(folder?.id);

  bool get _isRoot => folder == null;
  bool get _isLimitFolder => folder?.parentId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceAsync = ref.watch(_foldersPreferenceProvider);
    final theme = Theme.of(context);
return preferenceAsync.when(
      loading: () => const ScaffoldLoading(),
      error: (err, _) {
        debugPrint('_HomePage.build Error: $err');
        return const Scaffold(body: Center(child: Text('Error: preferences')));
      },
      data: (preference) {
        final showFolders = _isLimitFolder
            ? false
            : preference == FolderDefaultView.folders;

        // --- ENVOLVEMOS EL SCAFFOLD AQUÍ ---
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // <--- Quita el foco de cualquier TextField
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: _appBar(showFolders, preference, ref),
            // floatingActionButton: _floatingActionButton(showFolders),
            body: SafeArea(
              child: Column(
                children: [
                  BannerPendingNote(
                    key: const ValueKey('banner_note'),
                    toFolderId: folder?.id,
                    onToggleView: () => _selectView(FolderDefaultView.notes, ref),
                  ),
                  BannerPendingFolder(
                    key: const ValueKey('banner_folder'),
                    toParent: folder,
                    onToggleView: () => _selectView(FolderDefaultView.folders, ref),
                  ),
                  // Aquí es donde vive tu RootSearchSection que contiene el SearchListBar
                  if (_isRoot) const RootSearchSection(), 
                  
                  Expanded(
                    child: showFolders
                        ? FoldersSection(parentId: folder?.id)
                        : NotesSection(
                            folderId: folder?.id,
                            highlightNoteId: highlightNoteId,
                          ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SmartBannerAd(key: Key('global_banner')),
                const SizedBox(height: 8),
                if (!_isLimitFolder)
                  BottomButtonBar(
                    defaultview: preference,
                    onSelect: (newPreference) => _selectView(newPreference, ref),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar(bool showFolders, FolderDefaultView preference, WidgetRef ref) {
    if (_isRoot) {
      return AppBarPages(
        title: ref.tr(TKeys.pages.appName, fallback: 'Tag Links'),
        actions: [
          if (kDebugMode) GoDebugPageButon(),
          const ManualSyncButton(),
          const GoSettingsButton(),
          _creationButton(showFolders),
        ],
      );
    }
    return AppBarPages(title: folder!.title, actions:[_creationButton(showFolders)]);
  }

  /// 🔁 Cambiar vista y guardar preferencia
  Future<void> _selectView(FolderDefaultView select, WidgetRef ref) async {
    return await ref
        .read(_foldersPreferenceProvider.notifier)
        .updatePreference(select);
  }

  /// ➕ FAB dinámico
  Widget _creationButton(bool showFolders) {
    return showFolders
        ? CreateNewFolderButton(parentFolderId: folder?.id)
        : CreateNewNoteButton(folderId: folder?.id);
  }
}
