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
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).cardTheme.color,
        ),
      ),
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              tooltip: currentColorEnum == null
                  ? 'Seleccionar color'
                  : 'Color: ${currentColorEnum.name}',
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
                    color:
                        currentColorEnum?.text.withAlpha(120) ??
                        Theme.of(context).primaryIconTheme.color??Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    if(currentColorEnum != null) BoxShadow(
                      color: currentColorEnum.text.withAlpha(40),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: currentColorEnum == null
                    ? Icon(
                        Icons.palette_outlined,
                        size: 14,
                      )
                    : null,
              ),
            );
          },

      // Lista de opciones de la ventana emergente flotante
      menuChildren: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ColorCircle(
                selected: selectedColor == null,
                onTap: () => onChanged(null),
                child: const Icon(Icons.close, size: 14),
              ),

              for (final color in DecorateColor.values)
                _ColorCircle(
                  color: color,
                  selected: selectedColor == color.name,
                  onTap: () => onChanged(color.name),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final DecorateColor? color;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  const _ColorCircle({
    this.color,
    required this.selected,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color?.strong,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? color?.acent ?? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child:
            child ??
            (selected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null),
      ),
    );
  }
}
