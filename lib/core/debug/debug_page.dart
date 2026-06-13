import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/interstitial_ads_provider.dart';
import 'package:tag_links/core/auth/skiped_auth_provider.dart';
import 'package:tag_links/core/locate/lang_selector.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/media_in_coming/pending_note_provider.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/core/theme/theme_selector_widget.dart';
import 'package:tag_links/sync/widgets/manual_sync_button.dart';
import 'package:tag_links/ui/modals/confirm_dialog.dart';
import 'package:tag_links/ui/app_bar/app_bar_folder.dart';
import 'package:tag_links/ui/button/go_settings_button.dart';
import 'package:tag_links/ui/folder/folder_tile.dart';
import 'package:tag_links/ui/form/note_mini_form.dart';
import 'package:tag_links/ui/menu/menu_container.dart';
import 'package:tag_links/ui/note/banner_pending_note.dart';
import 'package:tag_links/ui/note/note_tile.dart';
import 'package:tag_links/ui/tags/show_create_tag_modal.dart';

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
        const SizedBox(height: 6),
        AppBarPages(
          title: "titulo",
          actions: [const ManualSyncButton(), const GoSettingsButton()],
        ),
        const SizedBox(height: 6),
        _cleanAdsCache(context, ref),
        BannerPendingNote(
          toFolderId: null,
          onToggleView: () async {},
          pendingNote: TypeNoteMove(
            note: Note.baseNote(fileId: "pruebas"),
            type: TypeMove.prueba,
          ),
        ),
        const SizedBox(height: 6),
        MyAlertDialog(
          title: "Dialogo de prueba",
          cancel: "cancelar",
          confirm: "aceptar",
        ),
        Padding(
          padding: EdgeInsetsGeometry.directional(start: 50, end: 15),
          child: ActionMenuView(
            items: [
              ActionMenuItem(icon: Icons.departure_board, label: "prueba"),
              ActionMenuItem(icon: Icons.catching_pokemon, label: "prueba"),
            ],
            onClose: () {},
          ),
        ),
        NoteTile(
          note: Note(
            id: "",
            folderId: "",
            fileId: "",
            title: "Nota de prueba",
            content: "Contenido de la nota de prueba",
            link: null,
            tags: [],
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
          onDeleteNote: () {
            debugPrint("onDeleteNote: nothing");
          },
          onMove: (Note nothing) {
            debugPrint("onMove: nothing");
          },
        ),
        FolderTile(
          folder: Folder(
            id: "",
            fileId: "",
            title: "Carpeta de prueba",
            tags: [],
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
          actionsItems: [],
          onDeleteFolder: () {},
          onMove: () {
            debugPrint("onMove: nothing");
          },
          goFolder: () {},
        ),
        const SizedBox(height: 6),
        // Tags
        CreateTagWidget(
          createTagLabel: "prueba create tag",
          controller: TextEditingController(),
          nameTagLabel: "Name Tag Label",
          submit: ()async{},
        ),
        NoteMiniForm(folderId: null),
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
        "Limpiar cache",
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
    ref.read(skipedAuthProvider.notifier).clear();
  }
}
