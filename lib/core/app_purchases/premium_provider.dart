import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/app_purchases/listen_to_purchase_update.dart';

final premiumProvider =
    NotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

class PremiumNotifier extends Notifier<bool> {

  @override
  bool build() {
    _load();
    return true; // fallback inmediato
  }

  Future<void> _load() async {
    final isPremium = await InAppPurchaseManager.getPremiumStatus();
    state = isPremium;
  }

  Future<void> reload() async {
    _load();
  }
}
