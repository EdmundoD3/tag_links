import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';

class SwitchFavorite extends ConsumerWidget {
  final bool? isFavorite;
  final void Function() onChanged;

  const SwitchFavorite({
    super.key,
    required this.isFavorite,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Evaluamos: si es true, es favorito. Si es false o null, es "ver todo".
    final bool activeFilter = isFavorite == true;
    final tooltip = activeFilter
        ? ref.tr(TKeys.ui.viewOnlyFavorites , fallback: 'Ver solo favoritos')
        : ref.tr(TKeys.ui.viewAll, fallback:'Ver todo');

    return IconButton(
      onPressed: onChanged,
      // Usamos un tooltip para que el usuario entienda el cambio
      tooltip: tooltip,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // Un toque de suavidad
        child: _activeIcon(activeFilter),
      ),
    );
  }

  Icon _activeIcon(bool activeFilter) {
    return activeFilter
        ? const Icon(
            Icons
                .favorite, // Corazón lleno para resaltar que hay un filtro activo
            key: ValueKey('fav'),
            color: Colors.red,
          )
        : const Icon(
            Icons.favorite_border, // Corazón vacío para el estado "normal"
            key: ValueKey('all'),
            color: Colors.grey,
          );
  }
}
