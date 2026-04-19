import 'package:flutter/material.dart';
import 'package:tag_links/config/limit_config.dart';

class ContentController extends StatelessWidget {
  final TextEditingController contentCtrl;
  final String label;
  final VoidCallback onChange;

  const ContentController({
    super.key,
    required this.contentCtrl,
    required this.label,
    required this.onChange,
  });

  // Función para insertar caracteres en la posición actual del cursor
  void _insertText(String openTag, String closeTag) {
    final text = contentCtrl.text;
    final selection = contentCtrl.selection;

    // Si hay texto seleccionado, lo envuelve. Si no, inserta los símbolos y pone el cursor en medio.
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$openTag${selection.textInside(text)}$closeTag',
    );
    contentCtrl.text = newText;

    // Mover el cursor a una posición lógica
    contentCtrl.selection = TextSelection.collapsed(
      offset: selection.start + openTag.length,
    );
    onChange();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: contentCtrl,
      maxLength: LimitAppConfig.contentMaxLength,
      maxLines: null,
      minLines: 12,
      keyboardType: TextInputType.multiline,
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: theme.textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor?.withAlpha(50),
        contentPadding: const EdgeInsets.all(22),

        // --- AQUÍ METEMOS LOS BOTONES ---
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // Los empuja hacia abajo
            mainAxisSize: MainAxisSize.min, // Solo ocupa el espacio necesario
            children: [
              _FormatButton(
                icon: Icons.format_bold_rounded,
                onTap: () => _insertText('*', '*'),
              ),
              const SizedBox(height: 8), // Espacio vertical entre botones
              _FormatButton(
                icon: Icons.format_italic_rounded,
                onTap: () => _insertText('_', '_'),
              ),
            ],
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.dividerColor.withAlpha(20),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withAlpha(100),
            width: 1.5,
          ),
        ),
      ),
      onChanged: (_) => onChange(),
    );
  }
}

// Widget auxiliar para los botones de formato
class _FormatButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FormatButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(
          150,
        ), // Fondo sutil para el botón
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 18,
        ), // Un pelín más pequeño para que sea discreto
        onPressed: onTap,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(6),
        visualDensity: VisualDensity.compact,
        color:theme.textTheme.titleLarge?.color,
      ),
    );
  }
}
