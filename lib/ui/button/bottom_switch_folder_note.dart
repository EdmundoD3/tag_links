import 'package:flutter/material.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final Map<FolderDefaultView, int> _defaulViewIndex = {
  FolderDefaultView.folders: 0,
  FolderDefaultView.notes: 1,
};

class BottomButtonBar extends ConsumerWidget {
  final FolderDefaultView defaultview;
  final void Function(FolderDefaultView) onSelect;

  const BottomButtonBar({
    super.key,
    required this.defaultview,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
        height: 1, 
        thickness: 1, 
        color: theme.dividerColor.withValues(alpha: 0.1), // O tu color lavanda muy suave
      ),
        BottomNavigationBar(
          currentIndex: _defaulViewIndex[defaultview] ?? 0, // Pestaña activa
          onTap: (index) {
            debugPrint(index.toString());
            if (index == 0) return onSelect(FolderDefaultView.folders);
            return onSelect(FolderDefaultView.notes);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.folder_open),
              activeIcon: const Icon(Icons.folder),
              label: t(ref, "switchFolder", fallback: 'Carpetas'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.sticky_note_2_outlined),
              activeIcon: const Icon(Icons.sticky_note_2),
              label: t(ref, "switchNote", fallback: 'Notas'),
            ),
          ],
        ),
      ],
    );
  }
}

