import 'package:flutter/material.dart';

class ActionMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

class ActionMenu {
  static void showActionMenu({
    required BuildContext context,
    required Offset position,
    required List<ActionMenuItem> items,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Tap afuera → cerrar
            Positioned.fill(
              child: GestureDetector(
                onTap: () => entry.remove(),
                child: Container(color: Colors.transparent),
              ),
            ),

            Positioned(
              left: position.dx,
              top: position.dy,
              child: _ActionMenuView(
                items: items,
                onClose: () => entry.remove(),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(entry);
  }
}

class _ActionMenuView extends StatelessWidget {
  final List<ActionMenuItem> items;
  final VoidCallback onClose;

  const _ActionMenuView({
    required this.items,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2F3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            return InkWell(
              onTap: () {
                onClose();          // cerrar menú
                item.onTap?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(item.icon, size: 22, color: Colors.white70),
                    const SizedBox(width: 14),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
