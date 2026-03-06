import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/models/tag.dart';
Future<Tag?> showEditTagModal(
  BuildContext context,
  WidgetRef ref,
  Tag tag,
) {
  final nameCtrl = TextEditingController(text: tag.name);
  bool isFavorite = tag.isFavorite;

  return showModalBottomSheet<Tag>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final theme = Theme.of(context);
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
                  t(ref, 'editTag', fallback: 'Editar tag'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: t(ref, 'tagName', fallback: 'Nombre del tag'),
                  ),
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  title: Text(t(ref, 'markAsFavorite', fallback: 'Marcar como favorito')),
                  value: isFavorite,
                  onChanged: (value) {
                    setState(() => isFavorite = value);
                  },
                  secondary: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(t(ref, 'cancel', fallback: 'Cancelar')),
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
                      child: Text(t(ref, 'save', fallback: 'Guardar')),
                    ),
                  ],
                ),

                const Divider(),

                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete),
                  label: Text(t(ref, 'delete', fallback: 'Eliminar')),
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
