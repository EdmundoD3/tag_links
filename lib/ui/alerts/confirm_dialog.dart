import 'package:flutter/material.dart';
import 'package:tag_links/ui/alerts/feedback_alert_confirm.dart';

class ConfirmDialog {
  static Future<void> deleteNote(
    BuildContext context,
    Future<void> Function() onDelete,
  ) {
    return _deleteAction(
      context,
      onDelete,
      title: 'Eliminar nota',
      message: '¿Estás seguro de eliminar la nota?',
      succesText: 'Nota eliminada',
      errorText: 'Error al eliminar',
    );
  }

  static Future<void> deleteFolder(
    BuildContext context,
    Future<void> Function() onDelete,
  ) {
    return _deleteAction(
      context,
      onDelete,
      title: 'Eliminar carpeta',
      message: '¿Estás seguro de eliminar la carpeta?',
      succesText: 'Carpeta eliminada',
      errorText: 'Error al eliminar',
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
  required String message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // obliga a elegir opción
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(cancelText),
          ),
          FilledButton(
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
