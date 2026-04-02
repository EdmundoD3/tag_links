import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
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
                  ref.tr(TKeys.tags.edit, fallback: 'Editar tag'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: ref.tr(TKeys.tags.nameField, fallback: 'Nombre del tag'),
                  ),
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  title: Text(ref.tr(TKeys.ui.favorite, fallback: 'Marcar como favorito')),
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
                      child: Text(ref.tr(TKeys.actions.cancel, fallback: 'Cancelar')),
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
                      child: Text(ref.tr(TKeys.actions.save, fallback: 'Guardar')),
                    ),
                  ],
                ),

                const Divider(),

                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete),
                  label: Text(ref.tr(TKeys.actions.delete, fallback: 'Eliminar')),
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
