import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/ui/button/action_button.dart';
import 'package:tag_links/ui/tags/input_tag_widgets.dart';

class EditedTag {
  final Tag tag;
  final bool isDeleted;

  EditedTag({required this.tag, required this.isDeleted});
}

Future<EditedTag?> showEditTagModal(
  BuildContext context,
  WidgetRef ref,
  Tag tag,
) {
  final titleCtrol = TextEditingController(text: tag.title);
  bool isFavorite = tag.isFavorite;

  return showModalBottomSheet<EditedTag>(
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
                Row(
                  children: [
                    // 1. El título a la izquierda
                    Expanded(
                      child: Text(
                        ref.tr(TKeys.tags.edit, fallback: 'Editar tag'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    // 2. El corazón a la derecha
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => isFavorite = !isFavorite);
                      },
                      tooltip: ref.tr(
                        TKeys.ui.favorite,
                        fallback: 'Marcar como favorito',
                      ),
                    ),
                  ],
                ),
                InputTitleTag(
                  controller: titleCtrol,
                  label: ref.tr(
                    TKeys.tags.nameField,
                    fallback: 'Nombre del tag',
                  ),
                ),

                // Botones de acción (Guardar / Cancelar)
                Row(
                  children: [
                    ActionButtonFilled(
                      onPressed: () =>
                          Navigator.pop(context), // Retorna null (Cancelar)
                      label: ref.tr(TKeys.actions.cancel, fallback: 'Cancelar'),
                    ),
                    const Spacer(),
                    ActionButtonFilled(
                      onPressed: () {
                        // Retornamos el objeto con isDeleted en false
                        Navigator.pop(
                          context,
                          EditedTag(
                            isDeleted: false,
                            tag: tag.copyWith(
                              title: titleCtrol.text.trim(),
                              isFavorite: isFavorite,
                            ),
                          ),
                        );
                      },
                      label: ref.tr(TKeys.actions.save, fallback: 'Guardar'),
                    ),
                  ],
                ),

                const Divider(),

                // Botón de Eliminar
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  icon: const Icon(Icons.delete),
                  label: Text(
                    ref.tr(TKeys.actions.delete, fallback: 'Eliminar'),
                  ),
                  onPressed: () {
                    // Retornamos el objeto con isDeleted en true
                    Navigator.pop(
                      context,
                      EditedTag(tag: tag, isDeleted: true),
                    );
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
