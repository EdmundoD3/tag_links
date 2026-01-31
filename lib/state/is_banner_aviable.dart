import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final isAdsActiveProvider =
    NotifierProvider<IsAdsActiveNotifier, bool?>(IsAdsActiveNotifier.new);

class IsAdsActiveNotifier extends Notifier<bool?> {
  late final _AdsStorage _storage;

  @override
  bool? build() {
    _storage = _AdsStorage();
    _loadInitialStatus();
    // Importante: retornamos null para indicar que está "cargando" o es desconocido
    return null; 
  }

  Future<void> _loadInitialStatus() async {
    state = await _storage.getStatus();
  }

  Future<void> setStatus(bool value) async {
    state = value;
    await _storage.saveStatus(value);
  }

  /// Alterna el estado y lo persiste
  Future<void> toggle() async {
    final newValue = state == null ? true : !state!;
    state = newValue;
    await _storage.saveStatus(newValue);
  }
}


class _AdsStorage {
  static const String _key = 'ads_active_status';

  Future<void> saveStatus(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isActive);
  }

  Future<bool?> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key);
  }
}