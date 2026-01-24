import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/pages/home_page.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/pending_folder_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/tags/tags_selector_menu.dart';
import 'package:uuid/uuid.dart';

class FolderFormPage extends ConsumerStatefulWidget {
  final Folder? folder;
  final String? parentFolderId;
  final bool isRoot;

  const FolderFormPage({super.key, this.folder, this.parentFolderId, this.isRoot = false});

  bool get isEdit => folder != null;

  @override
  ConsumerState<FolderFormPage> createState() => _FolderFormPageState();
}

class _FolderFormPageState extends ConsumerState<FolderFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;

  List<Tag> _tags = [];
  bool _isFavorite = false;
  String? parentId;

  @override
  void initState() {
    super.initState();
    _tags = widget.folder?.tags ?? [];

    _titleCtrl = TextEditingController(text: widget.folder?.title ?? '');
    _descriptionCtrl = TextEditingController(
      text: widget.folder?.description ?? '',
    );
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
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Editar carpeta' : 'Nueva carpeta'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _onSave)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// Título
            _titleView(),

            const SizedBox(height: 16),
            _tagSelector(),
            const SizedBox(height: 16),

            /// Descripción
            _descriptionView(),

            const SizedBox(height: 16),

            _favoriteBtn(),

            const SizedBox(height: 24),

            /// Botón guardar
            _saveBtn(),

            FilledButton.tonalIcon(
              onPressed: _onChangeFolder,
              icon: const Icon(Icons.drive_file_move),
              label: const Text('Cambiar carpeta'),
            ),
          ],
        ),
      ),
    );
  }

  // widgets
  Widget _titleView() {
    return TextFormField(
      controller: _titleCtrl,
      decoration: const InputDecoration(
        labelText: 'Título',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El título es obligatorio';
        }
        return null;
      },
    );
  }

  Widget _descriptionView() {
    return TextFormField(
      controller: _descriptionCtrl,
      maxLines: 8,
      decoration: const InputDecoration(
        labelText: 'Descripción',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _tagSelector() {
    return TagsSelectorMenu(
      tags: _tags,
      onTagSelected: _onTagSelected,
      onDeletedTag: _onDeletedTag,
    );
  }

  Widget _favoriteBtn() {
    return SwitchListTile(
      title: const Text('Marcar como favorita'),
      value: _isFavorite,
      onChanged: (value) {
        setState(() => _isFavorite = value);
      },
    );
  }

  Widget _saveBtn() {
    return FilledButton.icon(
      icon: const Icon(Icons.check),
      label: Text(widget.isEdit ? 'Guardar cambios' : 'Crear carpeta'),
      onPressed: _onSave,
    );
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

    final desc = _descriptionCtrl.text.trim();

    final folder = Folder(
      id: widget.folder?.id ?? const Uuid().v4(),
      parentId: parentId,
      title: _titleCtrl.text.trim(),
      description: desc.isEmpty ? null : desc,
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
    final isConfirm = await showConfirmDialog(
      context,
      title: "Cambiar carpeta",
      message:
          "Cualquier cambio que no se almacenó se perderá si no se elige una carpeta. ¿Desea continuar?",
    );

    if (isConfirm != true) return;

    final folder = _captureFolder();
    ref.read(pendingFolderProvider.notifier).set(folder);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }
}
