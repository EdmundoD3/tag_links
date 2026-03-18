import 'dart:async';

import 'package:flutter/foundation.dart';
class Debouncer {
  final int milliseconds;
  Timer? _timer;
  VoidCallback? _action;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _action = action;
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void flush() {
    _timer?.cancel();
    _action?.call();
  }

  void dispose() {
    _timer?.cancel();
  }
}