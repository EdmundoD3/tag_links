import 'package:flutter/material.dart';

class BannerPending extends StatelessWidget {
  final String text;
  final Function? onClose;
  const BannerPending({
    super.key,
    required this.text,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(12),
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(child: Text(text, style: TextStyle(color: theme.hintColor))),
            if (onClose != null)
              IconButton(
                onPressed: () => onClose!(),
                icon: Icon(Icons.close, color: theme.hintColor),
              ),
          ],
        ),
      ),
    );
  }
}