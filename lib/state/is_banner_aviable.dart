import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/state/premium_provider.dart';

final isAdsActiveProvider = Provider<bool?>((ref) {
  final isPremium = ref.watch(premiumProvider);
  if (isPremium == true) return false;
  return ref.watch(adsActiveProvider);
});
final adsActiveProvider = NotifierProvider<AdsActiveNotifier, bool?>(
  AdsActiveNotifier.new,
);

class AdsActiveNotifier extends Notifier<bool?> {
  final _AdsStorage _storage = _AdsStorage();

  @override
  bool? build() {
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
