import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:uuid/uuid.dart';

class FolderFormPage extends ConsumerStatefulWidget {
  final Folder? folder;
  final String? parentFolderId;

  const FolderFormPage({super.key, this.folder, this.parentFolderId});

  bool get isEdit => folder != null;

  @override
  ConsumerState<FolderFormPage> createState() => _FolderFormPageState();
}

class _FolderFormPageState extends ConsumerState<FolderFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(text: widget.folder?.title ?? '');
    _descriptionCtrl = TextEditingController(
      text: widget.folder?.description ?? '',
    );
    _isFavorite = widget.folder?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final isUpdate = widget.folder?.id != null;
    final now = DateTime.now();

    final folder = Folder(
      id: widget.folder?.id ?? const Uuid().v4(),
      parentId: widget.folder?.parentId ?? widget.parentFolderId,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text,
      tags: widget.folder?.tags ?? [],
      image: widget.folder?.image,
      createdAt: widget.folder?.createdAt ?? now,
      updatedAt: now,
      isFavorite: _isFavorite,
    );

    final provider = foldersProvider(folder.parentId);
    if (isUpdate) {
      await ref.read(provider.notifier).updateFolder(folder);
    } else {
      await ref.read(provider.notifier).addFolder(folder);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Editar carpeta' : 'Nueva carpeta'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// Título
            TextFormField(
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
            ),

            const SizedBox(height: 16),

            /// Descripción
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// Favorito
            SwitchListTile(
              title: const Text('Marcar como favorita'),
              value: _isFavorite,
              onChanged: (value) {
                setState(() => _isFavorite = value);
              },
            ),

            const SizedBox(height: 24),

            /// Botón guardar
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: Text(widget.isEdit ? 'Guardar cambios' : 'Crear carpeta'),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
