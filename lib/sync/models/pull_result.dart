class PullResult {
  final bool success;        // ¿Terminó el proceso sin errores críticos?
  final bool notesChanged;   // ¿Se descargaron o borraron notas?
  final bool foldersChanged; // ¿Hubo cambios en carpetas?
  final bool tagsChanged;    // ¿Hubo cambios en etiquetas?

  PullResult({
    this.success = true,
    this.notesChanged = false,
    this.foldersChanged = false,
    this.tagsChanged = false,
  });

  // Un helper para saber si hubo cualquier cambio
  bool get anyChanges => notesChanged || foldersChanged || tagsChanged;

  // Para combinar resultados si separas el proceso de borrado del de datos
  PullResult merge(PullResult other) {
    return PullResult(
      success: success && other.success,
      notesChanged: notesChanged || other.notesChanged,
      foldersChanged: foldersChanged || other.foldersChanged,
      tagsChanged: tagsChanged || other.tagsChanged,
    );
  }
}