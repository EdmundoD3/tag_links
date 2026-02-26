import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/small_banner.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/pages/home_page.dart';
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
      const SmartBannerAd(),
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
    if (!_formKey.currentState!.validate()) return;

    final folder = _captureFolder();

    final provider = foldersProvider(parentId);

    if (widget.isEdit) {
      await ref.read(provider.notifier).updateFolder(folder);
    } else {
      await ref.read(provider.notifier).addFolder(folder);
    }

    if (mounted) {
      Navigator.pop(context);
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
