import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final notifier = ref.read(foldersProvider(widget.parentId).notifier);

    // Un solo bloque para el scroll infinito es suficiente
    if (position.pixels >= position.maxScrollExtent - 200 &&
        notifier.hasMore &&
        !notifier.isLoadingMore) {
      debugPrint('Cargando más carpetas para: ${widget.parentId ?? "Root"}');
      notifier.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Los datos dependen de si es Root (posible búsqueda) o subcarpeta
    final foldersAsync = widget.parentId == null
        ? ref.watch(foldersViewProvider)
        : ref.watch(foldersProvider(widget.parentId));

    // Las acciones siempre van al notifier del parentId correspondiente
    final notifier = ref.read(foldersProvider(widget.parentId).notifier);

    return BuildFoldersList(
      foldersAsync: foldersAsync,
      scrollController: _scrollController,
      notifier: notifier,
      onDeleteFolder: (id) async {
        await notifier.deleteFolder(id);

        // Solo invalidamos búsqueda si estamos en el Root
        if (widget.parentId == null) {
          ref.invalidate(folderSearchProvider);
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
