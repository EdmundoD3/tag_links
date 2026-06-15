import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/pending_folder_provider.dart';
import 'package:tag_links/ui/folder/build_folders_list.dart';
import 'package:tag_links/ui/modals/confirm_dialog.dart';

class FoldersSection extends ConsumerStatefulWidget {
  final String? parentId;

  const FoldersSection({super.key, required this.parentId});

  @override
  ConsumerState<FoldersSection> createState() => _FoldersSectionState();
}

class _FoldersSectionState extends ConsumerState<FoldersSection> {
  final ScrollController _scrollController = ScrollController();

  AsyncNotifierProvider<FoldersNotifier, List<Folder>> get _provider =>
      foldersProvider(widget.parentId);

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

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final notifier = ref.read(_provider.notifier);

    if (position.pixels >= position.maxScrollExtent - 200 &&
        notifier.hasMore &&
        !notifier.isLoadingMore) {
      notifier.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final foldersAsync = widget.parentId == null
        ? ref.watch(foldersViewProvider)
        : ref.watch(_provider);

    final notifier = ref.read(_provider.notifier);

    return BuildFoldersList(
      foldersAsync: foldersAsync,
      scrollController: _scrollController,
      isLoadingMore: notifier.isLoadingMore,
      onDeleteFolder: (folder) async {
        await notifier.deleteFolder(folder);

        if (widget.parentId == null) {
          ref.invalidate(folderSearchProvider);
        }
      },
      onMoveFolder: (folder) async {
        final isConfirm = await ConfirmDialog.moveFolder(context, ref);
        if (isConfirm == true) {
          ref.read(pendingFolderProvider.notifier).set(folder);
        }
      },
    );
  }
}
