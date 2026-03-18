import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/ads/interstitial_ads_provider.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/pending_folder_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/form/app_bar_form.dart';
import 'package:tag_links/ui/form/body_form.dart';
import 'package:tag_links/ui/form/form_auto_save_controller.dart';
import 'package:tag_links/ui/form/move_to_folder_button.dart';
import 'package:tag_links/ui/tags/tags_selector_menu.dart';
import 'package:tag_links/ui/form/title_form_controller.dart';
import 'package:tag_links/utils/debouncer.dart';
import 'package:uuid/uuid.dart';
import 'package:tag_links/core/locate/app_lang.dart';

class FolderFormPage extends ConsumerStatefulWidget {
  final Folder? folder;
  final String? parentFolderId;
  final bool isRoot;

  const FolderFormPage({
    super.key,
    this.folder,
    this.parentFolderId,
    this.isRoot = false,
  });

  bool get isEdit => folder != null;

  @override
  ConsumerState<FolderFormPage> createState() => _FolderFormPageState();
}

class _FolderFormPageState extends ConsumerState<FolderFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  Folder? _folder;
  List<Tag> _tags = [];
  bool _isFavorite = false;
  String? parentId;

  late final Debouncer _saveDebouncer;
  late final FormAutoSaveController<Folder> _autoSave;

  @override
  void initState() {
    super.initState();

    _folder = widget.folder;
    _tags = widget.folder?.tags ?? [];

    _titleCtrl = TextEditingController(text: widget.folder?.title ?? '');
    _isFavorite = widget.folder?.isFavorite ?? false;

    _saveDebouncer = Debouncer(milliseconds: 800);

    parentId = widget.isRoot
        ? null
        : widget.parentFolderId ?? _folder?.parentId;

    _autoSave = FormAutoSaveController<Folder>(
      onSave: (folder) async {
        final provider = foldersProvider(folder.parentId);

        if (widget.isEdit) {
          await ref.read(provider.notifier).updateFolder(folder);
        } else {
          await ref.read(provider.notifier).addFolder(folder);
        }
      },
      hash: (f) {
        final tagIds = f.tags.map((t) => t.id).toList()..sort();
        return '${f.title}|${tagIds.join(",")}|${f.isFavorite}|${f.parentId}';
      },
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _saveDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onSave();
      },
      child: BodyForm(formKey: _formKey, appBar: _appBar(), children: _body()),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBarForm(
      title: widget.isEdit
          ? t(ref, 'editFolder', fallback: 'Editar carpeta')
          : t(ref, 'newFolder', fallback: 'Nueva carpeta'),
      titleListenable: _titleCtrl,
      isFavorite: _isFavorite,
      onFavoriteToogle: _isFavoriteToogle,
      onSave: _onSave,
      isSaving: _autoSave.isSaving,
    );
  }

  List<Widget> _body() {
    return [
      TitleFormController(
        titleCtrl: _titleCtrl,
        label: t(ref, 'formFolderTitle', fallback: 'Nombre de la carpeta'),
        validatorMsg: t(
          ref,
          'formFolderTitleRequired',
          fallback: 'El título es obligatorio',
        ),
        onChange: () => _saveDebouncer.run(_scheduleAutoSave),
      ),

      const SizedBox(height: 16),

      TagsSelectorMenu(
        tags: _tags,
        onTagSelected: _onTagSelected,
        onDeletedTag: _onDeletedTag,
      ),

      const SizedBox(height: 24),

      MoveToFolderButton(
        onChangeFolder: _onChangeFolder,
        title: t(ref, 'moveToFolder', fallback: 'Mover'),
      ),
    ];
  }

  // 🔥 AUTO SAVE TRIGGER
  void _scheduleAutoSave() {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    final folder = _captureFolder();
    _autoSave.schedule(folder);
  }

  void _isFavoriteToogle() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    _saveDebouncer.run(_scheduleAutoSave);
  }

  void _onTagSelected(Tag tag) {
    if (_tags.any((t) => t.id == tag.id)) return;

    setState(() {
      _tags = [..._tags, tag];
    });

    _saveDebouncer.run(_scheduleAutoSave);
  }

  void _onDeletedTag(Tag tag) {
    setState(() {
      _tags = _tags.where((t) => t.id != tag.id).toList();
    });

    _saveDebouncer.run(_scheduleAutoSave);
  }

  Folder _captureFolder() {
    final now = DateTime.now();

    final folder = Folder(
      id: _folder?.id ?? const Uuid().v4(),
      parentId: parentId,
      title: _titleCtrl.text.trim(),
      tags: _tags,
      image: _folder?.image,
      createdAt: _folder?.createdAt ?? now,
      updatedAt: now,
      isFavorite: _isFavorite,
    );

    _folder = folder;
    return folder;
  }

  // 🔥 GUARDADO FINAL PRO
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    _saveDebouncer.dispose();

    final folder = _captureFolder();

    try {
      await _autoSave.flush(folder);

      final adService = ref.read(adServiceProvider);
      final tocaIntersticial = ref.read(showInterstitialAdsProvider);

      if (tocaIntersticial) {
        adService.showInterstitialAd(
          onAdClosed: () {
            ref.read(interstitialAdsProvider.notifier).registerAdShown();
            if (mounted) Navigator.pop(context);
          },
        );
        return;
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error en guardado final de carpeta: $e');
    }
  }

  Future<void> _onChangeFolder() async {
    final isConfirm = await ConfirmDialog.moveFolder(context, ref);

    if (isConfirm != true) return;

    final folder = _captureFolder();
    ref.read(pendingFolderProvider.notifier).set(folder);

    if (!mounted) return;
    Navigator.pop(context);
  }
}
