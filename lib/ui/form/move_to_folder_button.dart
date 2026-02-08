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
    return FilledButton.tonalIcon(
      onPressed: onChangeFolder,
      icon: const Icon(Icons.drive_file_move),
      label: Text(title),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.deepPurple, // Color de fondo
        foregroundColor: Colors.white,
      ),
    );
  }
}
