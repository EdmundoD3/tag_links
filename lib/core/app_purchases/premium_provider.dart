import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/core/app_purchases/in_app_purchase_manager.dart';
import 'package:tag_links/core/app_purchases/premium_local_data_source_provider.dart';

/// Provider que expone simplemente si el usuario es Premium o no.
final premiumStatusProvider = NotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

class PremiumNotifier extends Notifier<bool> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _purchaseManager = MobileInAppPurchaseManager();

  @override
  bool build() {
    final localDataSource = ref.watch(premiumLocalDataSourceProvider);

    final localState = localDataSource.getIsPremium();

    _initInAppPurchases(localDataSource);

    ref.onDispose(() => _subscription?.cancel());

    return localState;
  }

  Future<void> _initInAppPurchases(PremiumLocalDataSource localData) async {
    final inAppPurchase = InAppPurchase.instance;

    final bool available = await inAppPurchase.isAvailable().timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );

    final bool localState = localData.getIsPremium();

    if (!available) {
      state = localState;
      return;
    }

    await _subscription?.cancel();

    _subscription = inAppPurchase.purchaseStream.listen((purchases) async {
      try {
        final premiumInfo = await _purchaseManager.processPurchaseUpdates(
          purchases,
        );

        if (premiumInfo == null) return;

        final bool isNowPremium = premiumInfo.hasActivePremium;

        if (state != isNowPremium) {
          state = isNowPremium;
          await localData.setIsPremium(isNowPremium);
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Error procesando compras: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
    });

    final int lastRestore = localData.getLastRestore();

    final bool needsRestore =
        DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(lastRestore),
        ) >
        const Duration(days: 7);

    if (needsRestore) {
      try {
        await inAppPurchase.restorePurchases();

        await localData.setLastRestore(DateTime.now().millisecondsSinceEpoch);
      } catch (e, stackTrace) {
        debugPrint('❌ PremiumNotifier: Error restaurando compras: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}
