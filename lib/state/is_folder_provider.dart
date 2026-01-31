import 'package:flutter_riverpod/flutter_riverpod.dart';

final isFolderProvider =
    NotifierProvider<IsFolderNotifier, bool>(IsFolderNotifier.new);

class IsFolderNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }
}
