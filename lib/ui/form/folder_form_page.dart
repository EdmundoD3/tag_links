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

  List<Tag> _tags = [];
  bool _isFavorite = false;
  String? parentId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tags = widget.folder?.tags ?? [];

    _titleCtrl = TextEditingController(text: widget.folder?.title ?? '');
    _isFavorite = widget.folder?.isFavorite ?? false;
    if (widget.isRoot) {
      parentId = null;
    } else {
      parentId = widget.parentFolderId ?? widget.folder!.parentId;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BodyForm(formKey: _formKey, appBar: _appBar(), children: _body());
  }

  PreferredSizeWidget _appBar() {
    return AppBarForm(
      title: widget.isEdit ? 'Editar carpeta' : 'Nueva carpeta',
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
        title: t(ref, 'moveToFolder', fallback: 'Cambiar carpeta'),
      ),
    ];
  }

  void _isFavoriteToogle() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  // controllers
  void _onTagSelected(Tag tag) {
    if (_tags.any((t) => t.id == tag.id)) return;

    setState(() {
      _tags = [..._tags, tag];
    });
  }

  void _onDeletedTag(Tag tag) {
    setState(() {
      _tags = _tags.where((t) => t.id != tag.id).toList();
    });
  }

  Folder _captureFolder() {
    final now = DateTime.now();

    final folder = Folder(
      id: widget.folder?.id ?? const Uuid().v4(),
      parentId: parentId,
      title: _titleCtrl.text.trim(),
      tags: _tags,
      image: widget.folder?.image,
      createdAt: widget.folder?.createdAt ?? now,
      updatedAt: now,
      isFavorite: _isFavorite,
    );
    return folder;
  }

Future<void> _onSave() async {
  // 1. Validaciones iniciales
  if (_isSaving || !_formKey.currentState!.validate()) return;

  // 2. Bloqueamos el botón
  setState(() => _isSaving = true);

  try {
    final folder = _captureFolder();
    final provider = foldersProvider(parentId);

    // 3. Guardado en la base de datos
    if (widget.isEdit) {
      await ref.read(provider.notifier).updateFolder(folder);
    } else {
      await ref.read(provider.notifier).addFolder(folder);
    }

    // 4. Lógica de Anuncios
    final adService = ref.read(adServiceProvider);
    final tocaIntersticial = ref.read(showInterstitialAdsProvider);

    if (tocaIntersticial) {
      adService.showInterstitialAd(
        onAdClosed: () {
          // Registramos que se mostró para el cooldown de 2 días
          ref.read(interstitialAdsProvider.notifier).registerAdShown();
          if (mounted) Navigator.pop(context); // Cierra después del anuncio
        },
      );
      // Salimos de la función aquí para que no ejecute el pop de abajo
      return; 
    }

    // 5. Si NO hubo anuncio, cerramos normalmente
    if (mounted) Navigator.pop(context);

  } catch (e) {
    // Si algo falla, liberamos el botón para que el usuario pueda reintentar
    if (mounted) {
      setState(() => _isSaving = false);
      // Opcional: Mostrar un mensaje de error si el guardado falló
    }
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
