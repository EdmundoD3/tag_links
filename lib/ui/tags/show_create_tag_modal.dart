import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:uuid/uuid.dart';

Future<Tag?> showCreateTagModal({
  required BuildContext context,
  required WidgetRef ref,
  String? initText,
}) {
  final controller = TextEditingController(text: initText);
  final theme = Theme.of(context);
  return showModalBottomSheet<Tag>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(ref, 'createTag', fallback: 'Crear tag'),
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              cursorColor: theme.scaffoldBackgroundColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor?.withAlpha(60),
                labelText: t(ref, 'tagName', fallback: 'Nombre del tag'),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.hintColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.hintColor, width: 2),
                ),
              ),
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () =>
                    _submit(context: context, controller: controller, ref: ref),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      theme.scaffoldBackgroundColor, // Color de fondo
                  foregroundColor:
                      theme.textTheme.titleLarge?.color, // Color del texto
                ),
                child: Text(t(ref, 'createTag', fallback: 'Crear tag')),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _submit({
  required BuildContext context,
  required WidgetRef ref,
  required TextEditingController controller,
}) async {
  final name = controller.text.trim();
  if (name.isEmpty) return;
  final notifier = ref.read(tagsProvider.notifier);
  final existTag = await notifier.getByExactlyName(name);
  if (existTag != null) {
    if (context.mounted) Navigator.pop(context, existTag);
  }
  final Tag newTag = Tag(id: const Uuid().v4(), name: name);
  await notifier.addTag(newTag);
  if (!context.mounted) return;
  Navigator.pop(context, newTag);
}
