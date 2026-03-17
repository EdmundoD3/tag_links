import 'package:flutter/material.dart';
import 'package:tag_links/models/folder_preference.dart';

final Map<FolderDefaultView, int> _defaulViewIndex = {
  FolderDefaultView.folders: 0,
  FolderDefaultView.notes: 1,
};

class BottomButtonBar extends StatelessWidget {
  final FolderDefaultView defaultview;
  final void Function(FolderDefaultView) onSelect;

  const BottomButtonBar({
    super.key,
    required this.defaultview,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _defaulViewIndex[defaultview] ?? 0, // Pestaña activa
      onTap: (index) {
        debugPrint(index.toString());
        if (index == 0) return onSelect(FolderDefaultView.folders);
        return onSelect(FolderDefaultView.notes);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_open),
          activeIcon: Icon(Icons.folder),
          label: 'Folders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sticky_note_2_outlined),
          activeIcon: Icon(Icons.sticky_note_2),
          label: 'Notas',
        ),
      ],
    );
  }
}
