import 'package:flutter/material.dart';
import 'package:tag_links/models/tag.dart';
Future<Tag?> showEditTagModal(
  BuildContext context,
  Tag tag,
) {
  final nameCtrl = TextEditingController(text: tag.name);
  bool isFavorite = tag.isFavorite;

  return showModalBottomSheet<Tag>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Editar tag',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del tag',
                  ),
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text('Marcar como favorito'),
                  value: isFavorite,
                  onChanged: (value) {
                    setState(() => isFavorite = value);
                  },
                  secondary: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : null,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          tag.copyWith(
                            name: nameCtrl.text.trim(),
                            isFavorite: isFavorite,
                          ),
                        );
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),

                const Divider(),

                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar tag'),
                  onPressed: () {
                    Navigator.pop(context, null); // señal de delete
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
