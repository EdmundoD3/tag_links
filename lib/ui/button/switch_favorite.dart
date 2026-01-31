import 'package:flutter/material.dart';

class SwitchFavorite extends StatelessWidget {
  final bool? isFavorite;
  final VoidCallback onChanged;

  const SwitchFavorite({
    super.key,
    required this.isFavorite,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Evaluamos: si es true, es favorito. Si es false o null, es "ver todo".
    final bool activeFilter = isFavorite == true;

    return IconButton(
      onPressed: onChanged,
      // Usamos un tooltip para que el usuario entienda el cambio
      tooltip: activeFilter ? 'Viendo solo favoritos' : 'Viendo todo',
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
