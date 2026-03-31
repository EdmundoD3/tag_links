import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';

class ReadMoreLabel extends ConsumerWidget {
  final bool isExpanded;
  const ReadMoreLabel({super.key, required this.isExpanded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Text(
      isExpanded
          ? t(ref, "readLess", fallback: "Ver menos...")
          : t(ref, "readMore", fallback: "Ver más..."),
      style: TextStyle(
        color: theme.badgeTheme.textColor, // <---- revisar color
        fontWeight: FontWeight.bold,
      ),
    );
  }
}