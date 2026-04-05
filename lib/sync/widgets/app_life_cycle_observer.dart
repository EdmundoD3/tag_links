import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/sync/sync_notifier_provider.dart';

class AppLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;
  const AppLifecycleObserver({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // IMPORTANTE: 'resumed' es cuando el usuario vuelve a ver la app
    if (state == AppLifecycleState.resumed) {
      debugPrint('⚡ App Resumed: Disparando sincronización de refresco.');

      // Accedemos al notifier para sincronizar
      // Usamos el delay de "App Start" o uno corto de seguridad
      unawaited(ref.read(syncProvider.notifier).synchronize());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
