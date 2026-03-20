import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/state/pending_folder_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/banners/banner_pending.dart';

class BannerPendingFolder extends ConsumerWidget {
  final Future<void> Function() onToggleView;
  final Folder? toParent; // esto proviene de la pagina que se muestra
  const BannerPendingFolder({
    super.key,
    required this.toParent,
    required this.onToggleView,
  });
  //nivel 0 es root o sea sin folder, 1 es folder y 2 es subFolder
  bool get _isInFolder => toParent != null;
  bool get _isSubFolder => _isInFolder && toParent?.id != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(pendingFolderProvider);
    //si no ha
    if (folder == null) return const SizedBox.shrink();

    if (_isSubFolder) {
      return BannerPending(
        title: t(
          ref,
          'alertMoveFolderErrorIsDeepFolder',
          fallback: "No puedes almacenar carpetas aquí, elije otra carpeta",
        ),
        actions: [_discard(context, ref)],
      );
    }

    // 1. Forzamos la lectura del provider de validación
    final validationAsync = ref.watch(folderValidationProvider(folder.id));

    return validationAsync.when(
      data: (folderValidation) {
        debugPrint(
          "✅ Validación cargada: Hijos=${folderValidation.hasChildren}\n isSubFolder:$_isInFolder",
        );

        final isSameFolder = folder.id == toParent?.id;

        if (isSameFolder) {
          return BannerPending(
            title: t(ref, 'alertMoveFolderErrorIsSameFolder'),
            actions: [_discard(context, ref)],
          );
        }
        final isForbidden = folderValidation.forbiddenIds.contains(
          toParent?.id,
        );

        return BannerPending(
          title: t(ref, 'alertMovePendingFolder'),
          actions: [
            // Solo mostramos el botón si no es una zona prohibida
            if (!isForbidden)
              BannerOptionsTile(
                onTap: () async {
                  debugPrint('按钮 Click: Intentando guardar...');

                  // CASO: SUB-CARPETA + HIJOS -> DIÁLOGO
                  if (_isInFolder && folderValidation.hasChildren) {
                    debugPrint('Trigger: Mostrando Diálogo de límite...');

                    // PRUEBA ESTO: Usa un showDialog básico para descartar que sea tu ConfirmDialog
                    final bool? confirm =
                        await ConfirmDialog.moveFormLimitReached(context, ref);
                    debugPrint('confirm:${confirm.toString()}');
                    if (confirm == true && context.mounted) {
                      await onToggleView();
                      await ref
                          .read(folderMoveProvider)
                          .moveAndFlatten(
                            folder: folder,
                            toParentId: toParent?.id,
                          );
                    }
                  }
                  // CASO: MOVIMIENTO NORMAL
                  else {
                    debugPrint('Trigger: Movimiento normal directo');
                    await onToggleView();
                    await ref
                        .read(folderMoveProvider)
                        .move(folder: folder, toParentId: toParent?.id);
                  }
                },
                title: t(ref, 'store'),
              ),
            _discard(context, ref),
          ],
        );
      },
      // 2. IMPORTANTE: No devuelvas shrink() aquí mientras debugueas
      loading: () {
        debugPrint("⏳ Cargando validación...");
        return const LinearProgressIndicator(); // Para ver que algo está pasando
      },
      error: (err, stack) {
        debugPrint("❌ Error en provider: $err");
        return Text("Error: $err");
      },
    );
  }

  BannerOptionsTile _discard(BuildContext context, WidgetRef ref) {
    return BannerOptionsTile(
      onTap: () async {
        // 1. Mostramos el diálogo PRIMERO.
        final confirm = await showConfirmDialog(
          context,
          title: t(ref, 'bannerNotMove'),
          message: t(ref, 'discardAction'),
          ref: ref,
        );

        // 2. Si confirma, limpiamos Todo rápido
        if (confirm == true) {
          debugPrint('--> EJECUTANDO CLEAR');
          // Limpiamos el provider de la carpeta pendiente (esto quita el banner de la vista)
          ref.read(pendingFolderProvider.notifier).clear();

          // Ejecutamos el cambio de vista sin bloquear (unawaited)
          // No necesitamos esperar a que la DB termine para que el banner desaparezca
          if (context.mounted) {
            onToggleView();
          }
        }
      },
      title: t(ref, 'discard'),
    );
  }
}
