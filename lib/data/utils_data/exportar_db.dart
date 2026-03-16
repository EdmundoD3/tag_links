import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tag_links/data/database.dart';
enum LocalBackUpResult { success, failure, error }
Future<LocalBackUpResult> exportarBaseDeDatos() async {
  try {
      // 1. Obtener la ruta de la base de datos real
  final dbPath = await AppDatabase().dbPath;
  final file = File(dbPath);

  if (await file.exists()) {
    // 2. Compartir el archivo directamente
    await SharePlus.instance.share(
      ShareParams(
        title: "Respaldo de mi Base de Datos",
        files: [XFile(dbPath)],
        fileNameOverrides: ['local_back_up.db'],
        text: 'Este archivo contiene todas tus carpetas, notas y etiquetas.',
        subject: 'Respaldo de mi Base de Datos',
      ),
    );
  return LocalBackUpResult.success;
  } else {
    debugPrint("No se encontró el archivo de base de datos.");
    return LocalBackUpResult.failure;
  }
  } catch (e) {
    debugPrint("Error al compartir el archivo: $e");
    return LocalBackUpResult.error;
  }
}
