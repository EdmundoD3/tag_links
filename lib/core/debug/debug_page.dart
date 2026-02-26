import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/interstitial_ads_provider.dart';
import 'package:tag_links/core/locate/lang_selector.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/core/theme/theme_selector_widget.dart';
import 'package:tag_links/ui/folder/folder_tile.dart';
import 'package:tag_links/ui/note/note_tile.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado (null al inicio, luego el valor de SharedPreferences)
    final adsActive = ref.watch(isAdsActiveProvider);

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Debug",
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
      ),
      body: _buildBody(context, ref, adsActive),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, bool? adsActive) {
    return ListView(
      children: [
        ThemeSelector(),
        LangSelector(),
        _cleanAdsCache(context, ref),
        NoteTile(
          note: Note(
            id: "",
            folderId: "",
            title: "Nota de prueba",
            content: "Contenido de la nota de prueba",
            link: null,
            tags: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          onDeleteNote: (String nothing) {
            debugPrint("onDeleteNote: nothing");
          },
        ),
        FolderTile(
          folder: Folder(
            id: "",
            title: "Carpeta de prueba",
            tags: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now()
          ),
          actionsItems: [],
          onDeleteFolder: () {
            
          },
          goFolder: (){},
        ),
      ],
    );
  }

  Widget _cleanAdsCache(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const Icon(
        Icons.card_giftcard,
        color: Colors.blueAccent,
        size: 40,
      ),
      title: Text(
        "Limpiar cache de anuncios",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      subtitle: Text(
        "Haz clic aquí para limpiar la cache de anuncios.",
        style: TextStyle(color: theme.hintColor),
      ),
      onTap: () => _cleanCache(ref),
    );
  }

  void _cleanCache(WidgetRef ref) {
    ref.read(adsDisabledUntilProvider.notifier).reset();
    ref.read(interstitialAdsProvider.notifier).reset();
  }
}
