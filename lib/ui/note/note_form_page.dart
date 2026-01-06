import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:uuid/uuid.dart';

class NoteFormPage extends ConsumerStatefulWidget {
  final Note? note;
  final String folderId;

  const NoteFormPage({
    super.key,
    this.note,
    required this.folderId,
  });

  bool get isEdit => note != null;

  @override
  ConsumerState<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends ConsumerState<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _isFavorite = widget.note?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();

    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      folderId: widget.folderId,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim().isEmpty
          ? null
          : _contentCtrl.text.trim(),
      link: widget.note?.link,
      tags: widget.note?.tags ?? const [],
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      isFavorite: _isFavorite,
    );

    final provider = notesProvider(widget.folderId);

    if (widget.isEdit) {
      await ref.read(provider.notifier).updateNote(note);
    } else {
      await ref.read(provider.notifier).addNote(note);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Editar nota' : 'Nueva nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
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

            /// Contenido
            TextFormField(
              controller: _contentCtrl,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                alignLabelWithHint: true,
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

            /// Guardar
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: Text(widget.isEdit ? 'Guardar cambios' : 'Crear nota'),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
