import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/ui/button/floating_button_base.dart';
import 'package:tag_links/ui/form/folder_form_page.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class CreateNewFolderButton extends ConsumerWidget {
  final String? parentFolderId;

  const CreateNewFolderButton({super.key, required this.parentFolderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingButtonBase(
      heroTag: t(ref, 'createFolder', fallback: 'Crear carpeta'),
      icon: Icons.create_new_folder,
      onPressed: () async {
        final fileId = await ref
            .read(localSyncQueueRepositoryProvider)
            .getOrCreateAvailableFileId(TypeQueue.folders);
        if (context.mounted) {
          goPage(
            context: context,
            page: FolderFormPage(
              parentFolderId: parentFolderId,
              fileId: fileId,
            ),
          );
        }
      },
    );
  }
}
