import 'package:flutter/material.dart';
import 'package:tag_links/ui/text/decorated_text.dart';

class ExpandableDecoratedText extends StatelessWidget {
  final String text;
  final int maxLines;
  final bool isExpanded;
  /// Callback para informar al padre si el texto realmente excede las líneas
  final Function(bool)? onLineCountCheck; 

  const ExpandableDecoratedText({
    super.key,
    required this.text,
    required this.isExpanded,
    this.onLineCountCheck,
    this.maxLines = 3,
  });

  void _checkTextExceeds(BuildContext context) {
    if (onLineCountCheck == null) return;

    final span = TextSpan( //basado en decorated text para tener el tamaño real
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 14,
        ),
        text: text,
      );

    final tp = TextPainter(
      text: span,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      
      // Usamos el ancho real del render box
      final double width = context.size?.width ?? 300;
      tp.layout(maxWidth: width);
      
      // Notificamos al padre el resultado de la medición
      onLineCountCheck!(tp.didExceedMaxLines);
    });
  }

  @override
  Widget build(BuildContext context) {

    final decoratedText = DecoratedText(
        text: text,
        maxLines: isExpanded ? null : maxLines,
        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
      );
    // Ejecutamos la medición cada vez que se construye para asegurar precisión
    _checkTextExceeds(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.topCenter,
      curve: Curves.easeInOut,
      child: decoratedText,
    );
  }
}