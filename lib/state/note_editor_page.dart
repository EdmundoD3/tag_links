import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/tag.dart';
import '../models/note.dart';
import '../models/link_preview.dart';
import 'notes_notifier.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final String folderId;
  final Note? note;

  const NoteEditorPage({
    super.key,
    required this.folderId,
    this.note,
  });

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late final TextEditingController titleCtrl;
  late final TextEditingController urlCtrl;
  List<Tag> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    urlCtrl = TextEditingController(text: widget.note?.link?.url ?? '');
    _selectedTags = widget.note?.tags.toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nueva nota' : 'Editar nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final note = Note(
                id: widget.note?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                folderId: widget.folderId,
                title: titleCtrl.text,
                link: LinkPreview(url: urlCtrl.text,id: "",noteId: widget.note?.id??""),
                tags: _selectedTags,
                createdAt: widget.note?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              final notifier = ref.read(notesProvider(widget.folderId).notifier);
              widget.note == null
                  ? notifier.addNote(note)
                  : notifier.updateNote(note);

              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
            const SizedBox(height: 16),
            _selectorTags(),
          ],
        ),
      ),
    );
  }

  Widget _selectorTags() {
    return FutureBuilder<List<Tag>>(
      future: Future.value([
        Tag(id: "1", name: "test"),
        Tag(id: "2", name: "test2")
      ]), // Simulación de DB
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final availableTags = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              children: _selectedTags
                  .map((tag) => Chip(
                        label: Text(tag.name),
                        onDeleted: () {
                          setState(() {
                            _selectedTags.remove(tag);
                          });
                        },
                      ))
                  .toList(),
            ),
            Autocomplete<Tag>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<Tag>.empty();
                }
                return availableTags.where((Tag option) {
                  return option.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (Tag option) => option.name,
              onSelected: (Tag selection) {
                if (!_selectedTags.any((t) => t.id == selection.id)) {
                  setState(() {
                    _selectedTags.add(selection);
                  });
                }
              },
              fieldViewBuilder:
                  (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'Escribe para buscar o crear',
                  ),
                  onSubmitted: (String value) {
                    if (value.isNotEmpty) {
                      final existingTag = availableTags
                          .where((t) => t.name == value)
                          .firstOrNull;

                      final tag = existingTag ??
                          Tag(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: value,
                          );

                      if (!_selectedTags.any((t) => t.name == tag.name)) {
                        setState(() {
                          _selectedTags.add(tag);
                        });
                      }
                      textEditingController.clear();
                      focusNode.requestFocus();
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
