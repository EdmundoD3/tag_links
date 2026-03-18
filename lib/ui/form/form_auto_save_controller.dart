class FormAutoSaveController<T> {
  final Future<void> Function(T data) onSave;
  final String Function(T data) hash;

  FormAutoSaveController({required this.onSave, required this.hash});

  T? _pending;
  bool _isSaving = false;
  String? _lastSavedHash;
  Future<void>? _currentProcess;
  int _retryCount = 0;
  static const maxRetries = 3;

  void schedule(T data) {
    final newHash = hash(data);

    if (_lastSavedHash == newHash && _pending == null) return;

    _pending = data;

    if (_isSaving) return;

    _isSaving = true;
    _currentProcess = _process();
  }

  Future<void> _process() async {
    while (_pending != null) {
      final current = _pending!;
      _pending = null;

      try {
        await onSave(current);
        _lastSavedHash = hash(current);
        _retryCount = 0;
      } catch (e) {
        if (_retryCount < maxRetries) {
          _retryCount++;
          _pending = current;
        } else {
          _retryCount = 0;
          _pending = null;
        }
        break;
      }
    }

    _isSaving = false;

    if (_pending != null) {
      _isSaving = true;
      _currentProcess = _process();
    } else {
      _currentProcess = null; // ✅ limpieza solo si ya no hay nada
    }
  }

  Future<void> flush(T latest) async {
    schedule(latest);
    await (_currentProcess ?? Future.value());
  }

  bool get isSaving => _isSaving;
}
