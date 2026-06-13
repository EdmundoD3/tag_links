import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/google/models/auth_exeptions.dart';
import 'package:tag_links/sync/sync_notifier_provider.dart';
import 'dart:async';

import 'package:tag_links/ui/modals/confirm_dialog.dart';
class SyncFlowHandler {

  static Future<void> handleInteractiveLogin(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final exito = await _runAuthAction(
      context,
      ref,
      () => ref.read(authProvider.notifier).login(),
    );

    if (exito) {
      unawaited(ref.read(syncProvider.notifier).synchronize());
    }
  }

  static Future<void> handleSilentSyncCheck(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final exito = await _runAuthAction(
      context,
      ref,
      () => ref.read(authProvider.notifier).initSilentLogin(),
    );

    if (exito) {
      unawaited(ref.read(syncProvider.notifier).synchronize());
    }
  }

  static Future<bool> _runAuthAction(
    BuildContext context,
    WidgetRef ref,
    Future<bool> Function() action,
  ) async {
    try {
      return await action();
    } on AccountConflictException catch (e) {
      return _handleConflict(context, ref, e);
    }
  }

  static Future<bool> _handleConflict(
    BuildContext context,
    WidgetRef ref,
    AccountConflictException e,
  ) async {
    if (!context.mounted) return false;

    final quiereFusionar = await ConfirmDialog.accountConflict(
      context: context,
      ref: ref,
      emailViejo: e.emailViejo,
      emailNuevo: e.emailNuevo,
    );

    if (quiereFusionar) {
      await ref
          .read(authProvider.notifier)
          .forzarFusionDeCuenta(e.userIntruso);

      unawaited(
        ref.read(syncProvider.notifier).forceSynchronize(),
      );

      return true;
    }

    await ref.read(authProvider.notifier).logout();
    return false;
  }
}