import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:share_handler/share_handler.dart';
import 'package:tag_links/core/app_purchases/listen_to_purchase_update.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';
import 'package:tag_links/core/theme/theme_provider.dart';
import 'package:tag_links/state/url_provider.dart';
import 'package:tag_links/core/theme/app_theme.dart';
import 'package:tag_links/utils/handle_media_in_coming_url.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final StreamSubscription _subHandleUrl;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void initState() {
    super.initState();

    _subHandleUrl = ShareListener.stream.listen(_handleMedia);

    _initPurchaseStream();

    ShareListener.getInitial().then(_handleMedia);

  }

  void _handleMedia(SharedMedia? media) {
    return handleMedia(media, ref);
  }

  Future<void> _initPurchaseStream() async {
    if (_subscription != null) return;

    final available = await InAppPurchase.instance.isAvailable();
    if (!available || !mounted) return;

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error, stack) {
        debugPrint('Purchase stream error: $error');
      },
    );

    // IMPORTANTE: Pedimos a la tienda que nos envíe las compras activas
    // para actualizar la fecha de expiración (Heartbeat).
    await InAppPurchase.instance.restorePurchases();
  }

void _listenToPurchaseUpdated(List<PurchaseDetails> list) {
  assert(() {
    debugPrint('Purchase update: ${list.length}');
    return true;
  }());

  InAppPurchaseManager.listenToPurchaseUpdated(list);
  ref.read(premiumNotifierProvider.notifier).reload();
}


  @override
  void dispose() {
    _subHandleUrl.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(paletteProvider);
    
    return MaterialApp(
      theme: getPalette(palette: palette),
      home: const HomePage(),
    );
  }
}
