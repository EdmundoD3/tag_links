import 'package:flutter/material.dart';

class MoveToFolderButton extends StatelessWidget {
  final Future<void> Function() onChangeFolder;
  final String title;
  const MoveToFolderButton({
    super.key,
    required this.onChangeFolder,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.tonalIcon(
      onPressed: onChangeFolder,
      icon: const Icon(Icons.drive_file_move),
      label: Text(title),
      style: FilledButton.styleFrom(
        backgroundColor: theme.inputDecorationTheme.fillColor, // Color de fondo
        foregroundColor: theme.textTheme.titleLarge?.color, // Color del texto
        side: BorderSide(
          color: theme.focusColor, // Un púrpura más oscuro para que resalte
          width: 0.5, // Grosor del borde
        ),
      ),
    );
  }
}
