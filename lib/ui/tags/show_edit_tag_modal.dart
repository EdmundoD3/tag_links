import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/ui/button/action_button.dart';
import 'package:tag_links/ui/modals/show_app_modal.dart';
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
return showAppModal<EditedTag>(
  context: context,
  child: StatefulBuilder(
    builder: (context, setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
                  // 1. El título a la izquierda
                  ModalTitle(
                    title: ref.tr(TKeys.tags.edit),
                    trailing: IconButton(
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
                  ),

              InputTitleTag(
                controller: titleCtrol,
                label: ref.tr(TKeys.tags.nameField, fallback: 'Nombre del tag'),
              ),

              // Botones de acción (Guardar / Cancelar)
ModalActions(
  leading: ActionButtonFilled(
    onPressed: () => Navigator.pop(context),
    label: ref.tr(TKeys.actions.cancel),
  ),
  trailing: ActionButtonFilled(
    onPressed: () {
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
    label: ref.tr(TKeys.actions.save),
  ),
),

              const Divider(),

              // Botón de Eliminar
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.delete),
                label: Text(ref.tr(TKeys.actions.delete, fallback: 'Eliminar')),
                onPressed: () {
                  // Retornamos el objeto con isDeleted en true
                  Navigator.pop(context, EditedTag(tag: tag, isDeleted: true));
                },
              ),
            ],
        );
      },
    ),
  );
}
