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
    return Card(
      margin: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            if (onClose != null)
              IconButton(
                onPressed: () => onClose!(),
                icon: const Icon(Icons.close),
              ),
          ],
        ),
      ),
    );
  }
}