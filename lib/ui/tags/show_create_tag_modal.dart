import 'package:flutter/material.dart';
import 'package:tag_links/models/tag.dart';
import 'package:uuid/uuid.dart';

Future<Tag?> showCreateTagModal(BuildContext context) {
  final controller = TextEditingController();

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
            const Text(
              'Crear nuevo tag',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nombre del tag',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(context, controller),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => _submit(context, controller),
                child: const Text('Crear'),
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

  Navigator.pop(
    context,
    Tag(
      id: const Uuid().v4(),
      name: name,
    ),
  );
}
