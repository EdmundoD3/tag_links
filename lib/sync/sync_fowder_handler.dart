import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/account_conflict_dialog.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/google/models/auth_exeptions.dart';
import 'package:tag_links/core/google/models/silent_login_result.dart';
import 'package:tag_links/sync/last_sync_storage.dart';
import 'package:tag_links/sync/sync_notifier_provider.dart';
import 'dart:async';

class SyncFlowHandler {
  static Future<void> silentInitLogin(
    BuildContext context,
    WidgetRef ref,
    SyncMetadata syncInfo
  ) async {
    
    final lastPulledAt = syncInfo.lastPulledAt;
    if (lastPulledAt != null) {
      final ahora = DateTime.now().millisecondsSinceEpoch;
      const veinticuatroHoras = 24 * 60 * 60 * 1000;

      // ⏱️ Si ya venció el plazo de un día, forzamos el chequeo con el Handler
      if (ahora - lastPulledAt >= veinticuatroHoras) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SyncFlowHandler.handleSilentSyncCheck(context, ref);
        });
      }
    }
  }

  /// 🛠️ 1. FLUJO INTERACTIVO (Para botones manuales)
  static Future<void> handleInteractiveLogin(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final authState = ref.read(authProvider);

    // 🛡️ CORTOCIRCUITO: Si ya está autenticado y todo está OK,
    // solo sincronizamos y nos ahorramos el proceso de login.
    if (authState.isAuthenticated &&
        authState.lastResult == SilentLoginResult.success) {
      debugPrint(
        "🛡️ SyncFlowHandler: Ya autenticado. Saltando login interactivo.",
      );
      unawaited(ref.read(syncProvider.notifier).synchronize());
      return;
    }

    try {
      final exito = await ref.read(authProvider.notifier).login();
      if (exito) {
        unawaited(ref.read(syncProvider.notifier).synchronize());
      }
    } catch (e) {
      if (e is AccountConflictException) {
        if(!context.mounted) return;
        final quiereFusionar = await AccountConflictDialog.show(
          context: context,
          emailViejo: e.emailViejo,
          emailNuevo: e.emailNuevo,
        );

        if (quiereFusionar) {
          await ref
              .read(authProvider.notifier)
              .forzarFusionDeCuenta(e.userIntruso);
          unawaited(ref.read(syncProvider.notifier).forceSynchronize());
        } else {
          await ref.read(authProvider.notifier).logout();
        }
      }
    }
  }

  /// ⏳ 2. FLUJO SILENCIOSO (Para el Router de 24h y formularios de Notas/Folders)
  static Future<void> handleSilentSyncCheck(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final authState = ref.read(authProvider);

    // 🛡️ CORTOCIRCUITO: Si la sesión ya está perfectamente establecida,
    // no tocamos a Google, no verificamos nada, dejamos pasar al usuario al instante.
    if (authState.isAuthenticated &&
        authState.lastResult == SilentLoginResult.success) {
      debugPrint(
        "🛡️ SyncFlowHandler: Sesión activa y sana. Saltando verificación silenciosa.",
      );
      unawaited(ref.read(syncProvider.notifier).synchronize());
      return;
    }

    try {
      final exito = await ref.read(authProvider.notifier).initSilentLogin();
      if (exito) {
        unawaited(ref.read(syncProvider.notifier).synchronize());
      }
    } catch (e) {
      if (e is AccountConflictException) {
        if(!context.mounted) return;
        final quiereFusionar = await AccountConflictDialog.show(
          context: context,
          emailViejo: e.emailViejo,
          emailNuevo: e.emailNuevo,
        );

        if (quiereFusionar) {
          await ref
              .read(authProvider.notifier)
              .forzarFusionDeCuenta(e.userIntruso);
          unawaited(ref.read(syncProvider.notifier).forceSynchronize());
        } else {
          await ref.read(authProvider.notifier).logout();
        }
      }
    }
  }
}
