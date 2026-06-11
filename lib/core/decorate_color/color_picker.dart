import 'package:flutter/material.dart';
import 'package:tag_links/core/decorate_color/decorated_color_themes.dart';

class ColorPickerAppBarButton extends StatelessWidget {
  final String? selectedColor;
  final ValueChanged<String?> onChanged;

  const ColorPickerAppBarButton({
    super.key,
    required this.selectedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Buscamos el color actual en el Enum
    final currentColorEnum = DecorateColor.fromCode(selectedColor);
    final buttonBgColor = currentColorEnum?.strong ?? Colors.transparent;

    // MenuAnchor es ideal para el AppBar porque despliega el menú justo debajo del botón
    return MenuAnchor(
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          tooltip: currentColorEnum == null ? 'Seleccionar color' : 'Color: ${currentColorEnum.name}',
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          // Creamos un indicador circular limpio para la barra superior
          icon: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: buttonBgColor,
              shape: BoxShape.circle,
              border: Border.all(
                // Si es null (sin color), mostramos un borde grisáceo sutil
                color: currentColorEnum == null 
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: currentColorEnum == null
                ? Icon(
                    Icons.palette_outlined, 
                    size: 14, 
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  )
                : null,
          ),
        );
      },
      // Lista de opciones de la ventana emergente flotante
      menuChildren: [
        // Opción para limpiar el color (dejarlo en null)
        MenuItemButton(
          leadingIcon: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: const Icon(Icons.close, size: 12),
          ),
          onPressed: () => onChanged(null),
          child: const Text('Sin color'),
        ),
        
        // Mapeo dinámico de tus colores disponibles
        for (final colorEnum in DecorateColor.values)
          MenuItemButton(
            leadingIcon: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colorEnum.strong,
                shape: BoxShape.circle,
              ),
              child: selectedColor == colorEnum.name
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            onPressed: () => onChanged(colorEnum.name),
            child: Text(
              colorEnum.name.toUpperCase()[0] + colorEnum.name.substring(1),
            ),
          ),
      ],
    );
  }
}