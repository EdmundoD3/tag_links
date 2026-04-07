import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';

class EmptyTagsText extends ConsumerWidget {
  const EmptyTagsText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      ref.tr(TKeys.ui.noTagsFound, fallback: 'No se encontraron etiquetas'),
      style: TextStyle(color: Theme.of(context).hintColor),
    );
  }

}