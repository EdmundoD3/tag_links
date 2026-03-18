import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;
  VoidCallback? _currentAction; // Guardamos la referencia real

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _currentAction = action; // Actualizamos la acción más reciente
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _currentAction?.call();
      _currentAction = null; // Limpiamos al terminar
    });
  }

  void flush() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      _currentAction?.call();
      _currentAction = null;
    }
  }

  void dispose() {
    _timer?.cancel();
    _currentAction = null;
  }
}