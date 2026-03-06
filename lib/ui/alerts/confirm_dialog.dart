import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/ui/alerts/feedback_alert_confirm.dart';

class ConfirmDialog {
  static Future<void> deleteNote(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() onDelete,
  ) {
    return _deleteAction(
      context,
      onDelete,
      title: t(ref, 'alertDeleteNoteTitle', fallback: 'Eliminar nota'),
      message: t(
        ref,
        'alertDeleteNote',
        fallback: '¿Estás seguro de eliminar la nota?',
      ),
      succesText: t(ref, 'alertDeleteNoteSucces', fallback: 'Nota eliminada'),
      errorText: t(ref, 'alertDeleteNoteError', fallback: 'Error al eliminar'),
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
      title: t(ref, 'alertDeleteFolderTitle', fallback: 'Eliminar carpeta'),
      message: t(
        ref,
        'alertDeleteFolder',
        fallback: '¿Estás seguro de eliminar la carpeta?',
      ),
      succesText: t(
        ref,
        'alertDeleteFolderSucces',
        fallback: 'Carpeta eliminada',
      ),
      errorText: t(
        ref,
        'alertDeleteFolderError',
        fallback: 'Error al eliminar',
      ),
    );
  }

  static Future<bool?> moveFolder(BuildContext context, WidgetRef ref) {
    return showConfirmDialog(
      context,
      title: t(ref, 'alertMoveFolderTitle', fallback: 'Cambiar carpeta'),
      message: t(
        ref,
        'alertMoveFolder',
        fallback: '¿Estás seguro de mover la carpeta?',
      ),
    );
  }

  static Future<bool?> moveNote(BuildContext context, WidgetRef ref) async {
    return showConfirmDialog(
      context,
      title: t(ref, 'alertMoveNoteTitle', fallback: 'Cambiar carpeta'),
      message: t(
        ref,
        'alertMoveNote',
        fallback: '¿Estás seguro de mover la nota?',
      ),
    );
  }
}

Future<void> _deleteAction(
  BuildContext context,
  Future<void> Function() onDelete, {
  required String title,
  required String message,
  required String succesText,
  required String errorText,
}) async {
  final isDelete = await showConfirmDialog(
    context,
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

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String? message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
}) {
  final theme = Theme.of(context);
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // obliga a elegir opción
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(title, style: theme.textTheme.titleLarge,),
        content: message != null
            ? Text(message, style: TextStyle(color: theme.textTheme.bodySmall?.color))
            : null,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.textTheme.titleLarge?.color,
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(cancelText),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.inputDecorationTheme.fillColor, // Color de fondo
              foregroundColor: theme.textTheme.titleLarge?.color, // Color del texto
            ),

            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}
