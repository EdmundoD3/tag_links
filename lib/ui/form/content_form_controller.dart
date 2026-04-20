import 'package:flutter/material.dart';
import 'package:tag_links/config/limit_config.dart';
import 'package:tag_links/ui/style/input_style_form.dart';

class ContentController extends StatefulWidget {
  final TextEditingController contentCtrl;
  final String label;
  final VoidCallback onChange;

  const ContentController({
    super.key,
    required this.contentCtrl,
    required this.label,
    required this.onChange,
  });

  @override
  State<ContentController> createState() => _ContentControllerState();
}

class _ContentControllerState extends State<ContentController> {
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Escuchamos el foco para saber cuándo mostrar/ocultar
    _focusNode.addListener(() {
      setState(() {
        _isTyping = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // --- En tu State de ContentController ---

  void _insertText(String openTag, String closeTag) {
    final text = widget.contentCtrl.text;
    final selection = widget.contentCtrl.selection;

    // Posiciones seguras
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    String prefix = "";
    // Lógica de espacio automático para menciones y hashtags
    if (start > 0) {
      final charBefore = text.substring(start - 1, start);
      if (charBefore != " " && charBefore != "\n") {
        prefix = " ";
      }
    }

    final finalOpenTag = "$prefix$openTag";
    final selectedText = text.substring(start, end);
    final newText = text.replaceRange(
      start,
      end,
      '$finalOpenTag$selectedText$closeTag',
    );

    widget.contentCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + finalOpenTag.length + selectedText.length,
      ),
    );

    widget.onChange();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        //Pading para que permita sobre salir los botones especiales
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: TextFormField(
            controller: widget.contentCtrl,
            focusNode: _focusNode, // Asignamos el focusNode
            maxLength: LimitAppConfig.contentMaxLength,
            maxLines: 12,
            minLines: 8,
            keyboardType: TextInputType.multiline,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: theme.textTheme.bodyMedium?.color,
            ),
            decoration: InputStyleForm.inputDecoration(
              theme: theme,
              label: widget.label,
              contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            ),
            onChanged: (value) {
              // Si el usuario escribe, nos aseguramos de que el estado refleje actividad
              if (!_isTyping) setState(() => _isTyping = true);
              widget.onChange();
            },
          ),
        ),
        // Los botones con animación de opacidad
        Positioned(
          top: 0, // Nada de margen para que sobre salga
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isTyping ? 0.8 : 1.0, // Semi-transparente al escribir
            child: _DecoratorButtons(_insertText),
          ),
        ),
      ],
    );
  }
}

class _DecoratorButtons extends StatelessWidget {
  final void Function(String, String) _insertText;

  const _DecoratorButtons(this._insertText);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface.withAlpha(200),
      borderRadius: BorderRadius.circular(
        8,
      ), // Un poco más redondeado para el grupo largo
      elevation: 1, // Una sombra mínima para separarlo del fondo
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            _FormatButton(
              icon: Icons.format_bold_rounded,
              onTap: () => _insertText('**', '**'),
            ),
            _divider(theme),
            _FormatButton(
              icon: Icons.format_italic_rounded,
              onTap: () => _insertText('_', '_'),
            ),
            _divider(theme),
            _FormatButton(
              icon: Icons.format_underline_rounded,
              onTap: () => _insertText('__', '__'),
            ),
            _divider(theme),
            _FormatButton(
              icon: Icons.strikethrough_s_rounded,
              onTap: () => _insertText('~', '~'),
            ),
            _divider(theme),
            _FormatButton(
              icon: Icons.code_rounded,
              onTap: () => _insertText('`', '`'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Container(
      height: 16,
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.dividerColor.withAlpha(50),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FormatButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      // Usamos InkWell para un control total del área de toque
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        4,
      ), // Agrega esto para que el clic sea redondeado
      child: Padding(
        padding: const EdgeInsets.all(
          4.0,
        ), // Controlamos el área de toque manualmente
        child: Icon(
          icon,
          size: 18, // Un poco más grande para legibilidad, pero discreto
          color: theme.colorScheme.onSurfaceVariant, // Color más equilibrado
        ),
      ),
    );
  }
}
