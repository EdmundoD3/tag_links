import 'package:flutter/material.dart';

class FormAutoSaveController<T> {
  final Future<void> Function(T data) onSave;
  final String Function(T data) hash;

  FormAutoSaveController({required this.onSave, required this.hash});

  T? _pending;
  bool _isSaving = false;
  String? _lastSavedHash;
  Future<void>? _currentProcess;
  int _retryCount = 0;
    // Future<void> _flushProcess; // Para evitar múltiples flushes paralelos
  static const maxRetries = 3;

  // 🔥 NUEVO MÉTODO SYNC
  // Úsalo cuando guardes manualmente (ej. al seleccionar un Tag)
  void sync(T data) {
    _lastSavedHash = hash(data);
    _pending = null; // Limpiamos pendientes porque ya está al día
    debugPrint("✅ AutoSave Sincronizado externamente");
  }

  void schedule(T data) {
    final newHash = hash(data);

    // Si el contenido es igual al último guardado exitoso, no hacemos nada
    if (_lastSavedHash == newHash && _pending == null) return;

    _pending = data;

    if (_isSaving) return;

    _isSaving = true;
    _currentProcess = _process();
  }

  Future<void> _process() async {
    try {
      while (_pending != null) {
        final T current = _pending!;
        _pending = null;

        try {
          await onSave(current);
          _lastSavedHash = hash(current);
          _retryCount = 0;
        } catch (e) {
          debugPrint("❌ Error en AutoSave: $e");
          if (_retryCount < maxRetries) {
            _retryCount++;
            _pending = current; // Reintentar
            await Future.delayed(const Duration(milliseconds: 500)); // Espera un poco antes de reintentar
          } else {
            _retryCount = 0;
            _pending = null; 
          }
          break; // Salir del bucle en caso de error crítico
        }
      }
    } finally {
      // ✅ IMPORTANTE: Garantizamos que isSaving sea false pase lo que pase
      _isSaving = false;
      _currentProcess = null;
    }
  }



  Future<void> flush(T latest) async {
    schedule(latest);
    if (_currentProcess != null) {
      await _currentProcess;
    }
  }

  bool get isSaving => _isSaving;
}