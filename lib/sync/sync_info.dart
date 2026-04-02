// En tu pantalla de Ajustes/Cuenta
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/core/locate/time/format_time.dart';
import 'package:tag_links/sync/last_sync_storage.dart';

class BuildSyncInfo extends ConsumerWidget {
  const BuildSyncInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastSync = ref.watch(lastSyncTimestampProvider);
    final syncedStatus = lastSync == null
        ? ref.tr(TKeys.sync.notSynced)
        : "${ref.tr(TKeys.sync.lastSync)} ${ref.fmt(lastSync)}";
    return Column(
      children: [
        Text(
          "${ref.tr(TKeys.sync.stateSync, fallback: "Estado de sincronizado: ")} $syncedStatus",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
