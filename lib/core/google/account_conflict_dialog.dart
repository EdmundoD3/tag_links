import 'package:flutter/material.dart';

class AccountConflictDialog {
  static Future<bool> show({
    required BuildContext context,
    required String emailViejo,
    required String emailNuevo,
    //TODO Traducir
      String cambiarCuenta ="¿Cambiar de cuenta?",
     String fusionMsg ="",
     String cancelar ="CANCELAR",
    String si ="SÍ, FUSIONAR",
  }) async {
    String fusionMsg ="""Has iniciado sesión con una cuenta diferente.\n\n
            • Cuenta anterior: $emailViejo\n
            • Cuenta nueva: $emailNuevo\n\n
            Si continúas, las notas de este dispositivo se fusionarán con la nueva cuenta en Google Drive.""";
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Obliga al usuario a tomar una decisión
      builder: (context) {
        return AlertDialog(
          title:  Row(
            children: [
              const Icon(Icons.swap_horizontal_circle, color: Colors.orange),
              const SizedBox(width: 10),
              Text(cambiarCuenta),
            ],
          ),
          content: Text(
            fusionMsg,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // NO
              child: Text(cancelar, style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // SÍ
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(si),
            ),
          ],
        );
      },
    );

    return resultado ?? false;
  }
}