import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/ui/button/action_button.dart';
import 'package:tag_links/ui/modals/show_app_modal.dart';
import 'package:tag_links/ui/tags/input_tag_widgets.dart';
import 'package:uuid/uuid.dart';

Future<Tag?> showCreateTagModal({
  required BuildContext context,
  required WidgetRef ref,
  String? initText,
}) {
  final controller = TextEditingController(text: initText);
  return showAppModal<Tag>(
    context: context,
    child: CreateTagWidget(
      controller: controller,
      createTagLabel: ref.tr(TKeys.tags.create, fallback: 'Crear tag'),
      nameTagLabel: ref.tr(TKeys.tags.nameField, fallback: 'Nombre del tag'),
      submit: () async =>
          await _submit(context: context, controller: controller, ref: ref),
    ),
  );
}

class CreateTagWidget extends StatelessWidget {
  final String createTagLabel;
  final String nameTagLabel;
  final Future<void> Function() submit;

  final TextEditingController controller;

  const CreateTagWidget({
    super.key,
    required this.createTagLabel,
    required this.controller,
    required this.nameTagLabel,
    required this.submit,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModalTitle(title: createTagLabel),
        const SizedBox(height: 12),

        InputTitleTag(controller: controller, label: nameTagLabel),

        const SizedBox(height: 12),

        ModalActions(
          leading: const SizedBox.shrink(),
          trailing: ActionButtonFilled(
            onPressed: submit,
            label: createTagLabel,
          ),
        ),
      ],
    );
  }
}

Future<void> _submit({
  required BuildContext context,
  required WidgetRef ref,
  required TextEditingController controller,
}) async {
  final name = controller.text.trim();
  if (name.isEmpty) {
    FocusScope.of(context).requestFocus(FocusNode());
    return;
  }

  // 1. Quitar el foco inmediatamente para liberar el teclado
  FocusScope.of(context).unfocus();

  try {
    final notifier = ref.read(tagsProvider.notifier);
    final fileId = await ref
        .read(localSyncQueueRepositoryProvider)
        .getOrCreateAvailableFileId(TypeQueue.tags);
    // 3. Si no existe, crear el nuevo
    final Tag newTag = Tag(
      id: const Uuid().v4(),
      title: name,
      fileId: fileId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Guardamos DESPUÉS (en segundo plano)
    final savedTag = await notifier.addTag(newTag);

    // Cerramos PRIMERO para liberar la UI
    if (context.mounted) Navigator.pop(context, savedTag);
  } catch (e) {
    debugPrint("Error en _submit: $e");
  }
}
