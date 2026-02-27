import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';

void main() {
  // ✅ ESTA LÍNEA ES CLAVE: Inicializa el entorno de tests de Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('PremiumNotifier inicializa en false por defecto', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Como build() es asíncrono (_init), le damos un respiro
    final state = container.read(premiumNotifierProvider);
    expect(state, false);
  });
}