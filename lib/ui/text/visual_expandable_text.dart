import 'package:flutter/material.dart';
import 'package:tag_links/ui/text/decorated_text.dart';

class VisualExpandableText extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final double maxHeight; // El límite para decidir si mostrar el "ver más"

  const VisualExpandableText({
    super.key,
    required this.text,
    required this.isExpanded,
    this.maxHeight = 120.0, // Altura máxima antes de colapsar
  });

  // Reemplaza la parte del indicador en el build por esto:
  // Comparamos el tamaño intrínseco del texto con nuestro límite.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Detectamos si son solo emojis para que la medición del Painter sea exacta
        final onlyEmojis = RegExp(
          r'^[\u{1F000}-\u{1FFFF}\u{2600}-\u{27BF}\s]+$',
          unicode: true,
        ).hasMatch(text);

        final tp = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: onlyEmojis ? 32 : 14,
            ), // Sincronizado con DecoratedText
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final bool exceeds = tp.height > maxHeight;

        final textWidget = DecoratedText(text: text);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter, // Asegura que crezca hacia abajo
              child: isExpanded
                  ? textWidget
                  : ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxHeight),
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black,
                              Colors.black.withAlpha(128), // Punto intermedio
                              Colors.transparent,
                            ],
                            stops: const [0.5, 0.8, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: ClipRect(child: textWidget),
                      ),
                    ),
            ),
            // Solo mostramos el indicador si realmente el texto se corta
            if (exceeds && !isExpanded) _buildExpandIndicator(context),
          ],
        );
      },
    );
  }

  Widget _buildExpandIndicator(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none, // Permite que el botón "pise" el texto
      children: [
        // 1. La línea de sombra/gradiente
        Container(
          height: 20, // Altura de la sombra
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).cardColor.withOpacity(0.0),
                Theme.of(context).cardColor.withOpacity(0.8), // Sombra suave
              ],
            ),
          ),
        ),
        // 2. El botón flotante estilizado
        Transform.translate(
          offset: const Offset(
            0,
            6,
          ), // Lo bajamos para que quede a mitad de camino
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
