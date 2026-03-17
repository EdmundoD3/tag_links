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
  // ***** variables *******
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  Folder? _folder;
  List<Tag> _tags = [];
  bool _isFavorite = false;
  String? parentId;
  bool _isSaving = false;
  late final Debouncer _saveDebouncer;

  String? _lastSavedHash;

  // ***** builder *******
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onSave(); // Ejecuta la lógica de espera y guardado
      },
      child: BodyForm(formKey: _formKey, appBar: _appBar(), children: _body()),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBarForm(
      title: widget.isEdit
          ? t(ref, 'editFolder', fallback: 'Editar carpeta')
          : t(ref, 'newFolder', fallback: 'Nueva carpeta'),
      isFavorite: _isFavorite,
      onFavoriteToogle: _isFavoriteToogle,
      onSave: _onSave,
      isSaving: _isSaving,
    );
  }

  List<Widget> _body() {
    return [
      /// Título
      TitleFormController(
        titleCtrl: _titleCtrl,
        label: t(ref, 'formFolderTitle', fallback: 'Nombre de la carpeta'),
        validatorMsg: t(
          ref,
          'formFolderTitleRequired',
          fallback: 'El título es obligatorio',
        ),
        onChange: () => _saveDebouncer.run(_autoSave),
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

  // ***** controllers *******
  @override
  void initState() {
    super.initState();
    _folder = widget.folder;

    _tags = widget.folder?.tags ?? [];

    _titleCtrl = TextEditingController(text: widget.folder?.title ?? '');
    _isFavorite = widget.folder?.isFavorite ?? false;

    _saveDebouncer = Debouncer(milliseconds: 800);

    if (widget.isRoot) {
      parentId = null;
    } else {
      parentId = widget.parentFolderId ?? _folder?.parentId;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _saveDebouncer.dispose();
    super.dispose();
  }

  void _isFavoriteToogle() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    _saveDebouncer.run(_autoSave);
  }

  // controllers
  void _onTagSelected(Tag tag) {
    if (_tags.any((t) => t.id == tag.id)) return;

    setState(() {
      _tags = [..._tags, tag];
    });

    _saveDebouncer.run(_autoSave);
  }

  void _onDeletedTag(Tag tag) {
    setState(() {
      _tags = _tags.where((t) => t.id != tag.id).toList();
    });

    _saveDebouncer.run(_autoSave);
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

  Future<void> _onSave() async {
    // 1. Validar formulario primero
    if (!_formKey.currentState!.validate()) return;

    // 2. Detener el debouncer inmediatamente
    _saveDebouncer.dispose();

    // 3. Si el autosave está trabajando, esperamos a que termine
    while (_isSaving) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // 4. Bloqueamos para el guardado final
    setState(() => _isSaving = true);

    try {
      final folder = _captureFolder();
      final hash = _folderHash(folder);

      // 5. Solo guardamos si el último autosave no lo hizo ya
      if (_lastSavedHash != hash) {
        await _saveFolder(folder);
        _lastSavedHash = hash;
      }

      // 6. Lógica de Anuncios
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _autoSave() async {
    // Si ya se está guardando (sea por otro autosave o por el cierre), rebotamos
    if (_isSaving) return;
    if (_formKey.currentState == null || !_formKey.currentState!.validate())
      return;

    final folder = _captureFolder();
    final hash = _folderHash(folder);

    if (_lastSavedHash == hash) return;

    // Marcamos como ocupado
    _isSaving = true;

    try {
      await _saveFolder(folder);
      _lastSavedHash = hash;
    } catch (e) {
      debugPrint('Error autosave folder: $e');
    } finally {
      // Liberamos el flag para que otros procesos (como el cierre) puedan entrar
      _isSaving = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _saveFolder(Folder folder) async {
    final provider = foldersProvider(parentId);

    if (widget.isEdit) {
      await ref.read(provider.notifier).updateFolder(folder);
    } else {
      await ref.read(provider.notifier).addFolder(folder);
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

  String _folderHash(Folder f) {
    return '${f.title}|${f.tags.map((t) => t.id).join(",")}|${f.isFavorite}|${f.parentId}';
  }
}
