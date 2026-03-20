import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/app_purchases/in_app_purchase_manager.dart';
import 'package:tag_links/core/app_purchases/suscription_cache.dart';

void main() {
  // Inicializa SharedPreferences para tests
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Pruebas de InAppPurchaseManager', () async {
    final pref = await SharedPreferences.getInstance();
    final subscriptionCache = SubscriptionCache(pref);
    final premiumManager = PremiumManager(subscriptionCache);
    final inAppPurchaseManager = InAppPurchaseManager(premiumManager);
    test('includesPremium reconoce correctamente los IDs registrados', () {
      expect(inAppPurchaseManager.includesPremium('premium_monthly'), true);
      expect(inAppPurchaseManager.includesPremium('premium_yearly'), true);
      expect(inAppPurchaseManager.includesPremium('hack_id'), false);
    });

    test('getPremiumStatus devuelve false si no hay datos guardados', () async {
      final status = await inAppPurchaseManager.getPremiumStatus();
      expect(status, false);
    });

    test('getPremiumStatus devuelve true si la fecha de expiración es futura', () async {
      final prefs = await SharedPreferences.getInstance();
      final futura = DateTime.now().add(const Duration(days: 10));
      
      await prefs.setInt('premium_expiration_date', futura.millisecondsSinceEpoch);
      
      final status = await inAppPurchaseManager.getPremiumStatus();
      expect(status, true);
    });

    test('getPremiumStatus devuelve false si la fecha ya pasó', () async {
      final prefs = await SharedPreferences.getInstance();
      final pasada = DateTime.now().subtract(const Duration(days: 1));
      
      await prefs.setInt('premium_expiration_date', pasada.millisecondsSinceEpoch);
      
      final status = await inAppPurchaseManager.getPremiumStatus();
      expect(status, false);
    });
  });
}