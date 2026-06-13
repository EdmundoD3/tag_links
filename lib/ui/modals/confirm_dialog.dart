import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/ui/modals/text_dialog.dart';
import 'package:tag_links/ui/modals/feedback_alert_confirm.dart';

class ConfirmDialog {
  static Future<void> deleteNote(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() onDelete,
  ) {
    return _deleteAction(
      context,
      onDelete,
      title: ref.tr(TKeys.alerts.deleteNoteTitle, fallback: 'Eliminar nota'),
      message: ref.tr(
        TKeys.alerts.deleteNote,
        fallback: '¿Estás seguro de eliminar la nota?',
      ),
      succesText: ref.tr(
        TKeys.alerts.deleteNoteSuccess,
        fallback: 'Nota eliminada',
      ),
      errorText: ref.tr(
        TKeys.alerts.deleteNoteError,
        fallback: 'Error al eliminar',
      ),
      ref: ref,
    );
  }

  static Future<void> deleteFolder(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() onDelete,
  ) {
    return _deleteAction(
      context,
      onDelete,
      title: ref.tr(
        TKeys.alerts.deleteFolderTitle,
        fallback: 'Eliminar carpeta',
      ),
      message: ref.tr(
        TKeys.alerts.deleteFolder,
        fallback: '¿Estás seguro de eliminar la carpeta?',
      ),
      succesText: ref.tr(
        TKeys.alerts.deleteFolderSuccess,
        fallback: 'Carpeta eliminada',
      ),
      errorText: ref.tr(
        TKeys.alerts.deleteFolderError,
        fallback: 'Error al eliminar',
      ),
      ref: ref,
    );
  }

  static Future<void> deleteTag(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() onDelete,
  ) {
    return _deleteAction(
      context,
      onDelete,
      title: ref.tr(TKeys.alerts.deleteTagTitle, fallback: 'Eliminar etiqueta'),
      // Mensaje específico para advertir la permanencia
      message: ref.tr(
        TKeys.alerts.deleteTagPermanent,
        fallback:
            '¿Estás seguro de eliminar permanentemente esta etiqueta? Se quitará de todas las notas.',
      ),
      succesText: ref.tr(
        TKeys.alerts.deleteTagSuccess,
        fallback: 'Etiqueta eliminada para siempre',
      ),
      errorText: ref.tr(
        TKeys.alerts.deleteTagError,
        fallback: 'Error al intentar borrar la etiqueta',
      ),
      ref: ref,
    );
  }

  static Future<bool?> moveFolder(BuildContext context, WidgetRef ref) {
    return _showConfirmDialog(
      context,
      title: ref.tr(TKeys.alerts.moveFolderTitle, fallback: 'Cambiar carpeta'),
      message: ref.tr(
        TKeys.alerts.moveFolder,
        fallback: '¿Estás seguro de mover la carpeta?',
      ),
      ref: ref,
    );
  }

  static Future<bool?> moveNote(BuildContext context, WidgetRef ref) async {
    return _showConfirmDialog(
      context,
      title: ref.tr(TKeys.alerts.moveNoteTitle, fallback: 'Cambiar carpeta'),
      message: ref.tr(
        TKeys.alerts.moveNote,
        fallback: '¿Estás seguro de mover la nota?',
      ),
      ref: ref,
    );
  }

  static Future<bool?> discardForm(BuildContext context, WidgetRef ref) async {
    return _showConfirmDialog(
      context,
      title: ref.tr(TKeys.alerts.discard, fallback: 'Descatar cambios'),
      message: ref.tr(
        TKeys.alerts.discardFormTitle,
        fallback: 'Falta el título. ¿Quieres descartarla?',
      ),
      ref: ref,
    );
  }

  static Future<bool?> moveFormLimitReached(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return _showConfirmDialog(
      context,
      ref: ref,
      title: ref.tr(TKeys.alerts.limitReached, fallback: 'Límite de niveles'),
      message: ref.tr(
        TKeys.alerts.limitReachedMessage,
        fallback: "Esta carpeta tiene hijos. Se moverán a la raíz.",
      ),
    );
  }

  static Future<bool?> logout(BuildContext context, WidgetRef ref) async {
    return _showConfirmDialog(
      context,
      title: ref.tr(TKeys.auth.logOut, fallback: 'Cerrar sesión'),
      message: ref.tr(
        TKeys
            .auth
            .confirmLogoutMessage, // Asegúrate de tener esta llave o usa fallback
        fallback: '¿Estás seguro de que quieres cerrar sesión?',
      ),
      ref: ref,
    );
  }

  static Future<bool> accountConflict({
    required BuildContext context,
    required WidgetRef ref,
    required String emailViejo,
    required String emailNuevo,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Obliga al usuario a tomar una decisión
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.swap_horizontal_circle, color: Colors.orange),
              const SizedBox(width: 10),
              Text(
                ref.tr(
                  TKeys.auth.cambiarCuenta,
                  fallback: "¿Cambiar de cuenta?",
                ),
              ),
            ],
          ),
          content: Text(
            ref
                .tr(TKeys.auth.accountConflictMsg)
                .replaceAll('{emailViejo}', emailViejo)
                .replaceAll('{emailNuevo}', emailNuevo),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // NO
              child: Text(
                ref.tr(TKeys.actions.cancel, fallback: 'Cancelar'),
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // SÍ
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(
                ref.tr(TKeys.auth.siFusionar, fallback: "SÍ, FUSIONAR"),
              ),
            ),
          ],
        );
      },
    );
    return resultado ?? false;
  }

  static Future<bool?> discardPendingFolder({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    return await _showConfirmDialog(
      context,
      title: ref.tr(TKeys.alerts.notMove),
      message: ref.tr(TKeys.alerts.discardAction),
      ref: ref,
    );
  }

  static Future<bool?> discardPendingNote({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    return await _showConfirmDialog(
      context,
      title: ref.tr(TKeys.alerts.notMove, fallback: 'No mover la nota'),
      message: ref.tr(
        TKeys.alerts.discardAction,
        fallback: '¿Estás seguro de descartar la acción?',
      ),
      ref: ref,
    );
  }
}

Future<void> _deleteAction(
  BuildContext context,
  Future<void> Function() onDelete, {
  required WidgetRef ref,
  required String title,
  required String message,
  required String succesText,
  required String errorText,
}) async {
  final isDelete = await _showConfirmDialog(
    context,
    ref: ref,
    title: title,
    message: message,
  );
  if (isDelete != true) return;

  try {
    await onDelete();
    if (!context.mounted) return;
    feedbackAlertConfirm(context, succesText, backgroundColor: Colors.green);
  } catch (_) {
    if (!context.mounted) return;
    feedbackAlertConfirm(
      context,
      errorText,
      backgroundColor: Colors.deepOrangeAccent,
    );
  }
}

Future<bool?> _showConfirmDialog(
  BuildContext context, {
  required String title,
  required String? message,
  required WidgetRef ref,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // obliga a elegir opción
    builder: (context) {
      return MyAlertDialog(
        title: title,
        message: message,
        cancel: ref.tr(TKeys.actions.cancel, fallback: 'Cancelar'),
        confirm: ref.tr(TKeys.actions.accept, fallback: 'Aceptar'),
      );
    },
  );
}

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String cancel;
  final String confirm;

  const MyAlertDialog({
    super.key,
    required this.title,
    this.message,
    required this.cancel,
    required this.confirm,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: TextDialogTitle(title: title),
      content: message != null ? TextDialogContent(text: message!) : null,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.textTheme.titleLarge?.color,
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor:
                theme.inputDecorationTheme.fillColor, // Color de fondo
            foregroundColor:
                theme.textTheme.titleLarge?.color, // Color del texto
          ),

          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(confirm),
        ),
      ],
    );
  }
}
