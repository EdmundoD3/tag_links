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
    final int currentIndex = _defaulViewIndex[defaultview] ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Contenedor del indicador deslizable
        Stack(
          children: [
            Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
            // LINEA ANIMADA: Se desliza a la izquierda o derecha
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // Si hay 2 items, 0 es izquierda (-1.0) y 1 es derecha (1.0)
              alignment: currentIndex == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5, // Ocupa la mitad de la pantalla (un botón)
                child: Container(
                  height: 2,
                  color: theme.bottomNavigationBarTheme.selectedIconTheme?.color,
                ),
              ),
            ),
          ],
        ),
        BottomNavigationBar(
          elevation: 0,
          backgroundColor:Colors.transparent,
          currentIndex: currentIndex,
          onTap: (index) {
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
