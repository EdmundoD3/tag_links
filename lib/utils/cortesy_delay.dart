/// PAUSA DE CORTESÍA ESTRATÉGICA.
/// Si la lista de esta categoría es grande, pausamos a partir del décimo
class SyncPacer {
  final int threshold;
  final Duration delay;
  int _processed = 0;

  SyncPacer({this.threshold = 10, this.delay = const Duration(milliseconds: 50)});

  Future<void> step(int totalItems) async {
    if (totalItems >= threshold && _processed >= threshold) {
      await Future.delayed(delay);
    }
    _processed++;
  }
}