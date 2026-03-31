import 'package:flutter/material.dart';
import 'package:tag_links/ui/text/decorated_text.dart';
import 'package:tag_links/ui/text/read_more_label.dart';

class ExpandableDecoratedText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableDecoratedText({
    super.key,
    required this.text,
    this.maxLines = 3, // Número de líneas antes de cortar
  });

  @override
  State<ExpandableDecoratedText> createState() =>
      _ExpandableDecoratedTextState();
}

class _ExpandableDecoratedTextState extends State<ExpandableDecoratedText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, size) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: ConstrainedBox(
                constraints: isExpanded
                    ? const BoxConstraints()
                    : BoxConstraints(
                        maxHeight: widget.maxLines * 20.0,
                      ), // Estimación de altura
                child: DecoratedText(
                  text: widget.text,
                  // Agregamos estas propiedades a tu DecoratedText original
                  maxLines: isExpanded ? null : widget.maxLines,
                  overflow: isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
        if (widget.text.length > 100) // Solo mostrar si el texto es largo
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ReadMoreLabel(isExpanded: isExpanded),
            ),
          ),
      ],
    );
  }
}
