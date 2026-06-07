import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
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
    if (state == AppLifecycleState.resumed) {
      debugPrint('⚡ App Resumed: Preparando sincronización...');

      // 1. Evitamos disparar inmediatamente para dejar que la UI respire
      Future.delayed(const Duration(seconds: 3), () {
        // 2. Verificamos que el usuario siga en la app y esté autenticado
        // no necesitamos forzar iniciar sesion
        final auth = ref.read(authProvider);
        
        if (auth.isAuthenticated) {
          debugPrint('🚀 Ejecutando sync tras delay de estabilidad.');
          // Usamos synchronize (que tiene la lógica de cooldown) 
          // en lugar de forceSynchronize
          unawaited(ref.read(syncProvider.notifier).synchronize());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
