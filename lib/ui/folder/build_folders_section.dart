import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/ui/folder/build_folders_list.dart';

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

  void _onScroll() {
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
    // 1. Definimos qué fuente de datos usar
    // Si estamos en Root (null), dejamos que foldersViewProvider decida (Lista o Búsqueda)
    // Si estamos en Subcarpeta, vamos directo al foldersProvider
    final foldersAsync = widget.parentId == null
        ? ref.watch(foldersViewProvider)
        : ref.watch(foldersProvider(widget.parentId));

    // 2. El notifier siempre lo obtenemos del provider original para las acciones (CRUD/Paginación)
    final notifier = ref.read(foldersProvider(widget.parentId).notifier);

    return BuildFoldersList(
      foldersAsync: foldersAsync,
      scrollController: _scrollController,
      notifier: notifier,
      onDeleteFolder: (id) => notifier.deleteFolder(id),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
