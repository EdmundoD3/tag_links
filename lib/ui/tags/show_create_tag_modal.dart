import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/locate/app_lang.dart';
import 'package:tag_links/models/tag.dart';
import 'package:uuid/uuid.dart';

Future<Tag?> showCreateTagModal(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();
  final theme = Theme.of(context);
  return showModalBottomSheet<Tag>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.hintColor),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: t(ref, 'tagName', fallback: 'Nombre del tag'),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: theme.hintColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.focusColor, width: 2),
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(context, controller),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => _submit(context, controller),
                child: Text(t(ref, 'createTag', fallback: 'Crear tag')),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _submit(BuildContext context, TextEditingController controller) {
  final name = controller.text.trim();
  if (name.isEmpty) return;

  Navigator.pop(context, Tag(id: const Uuid().v4(), name: name));
}
