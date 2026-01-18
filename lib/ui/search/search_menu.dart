import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/tag.dart';

class SearchTags extends StatefulWidget {
  final String queryText;
  final AsyncValue<List<Tag>> tagsSuggestion;
  final void Function(String text) onChangeText;
  final void Function(Tag tag) onTagSelected;
  final Widget? iconButton;
  const SearchTags({
    super.key,
    required this.queryText,
    required this.tagsSuggestion,
    required this.onChangeText,
    required this.onTagSelected,
    this.iconButton,
  });

  @override
  State<SearchTags> createState() => _SearchTagsState();
}

class _SearchTagsState extends State<SearchTags> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.queryText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SearchTags oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.queryText != widget.queryText &&
        _controller.text != widget.queryText) {
      _controller.text = widget.queryText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  void _onChangeText(String text) {
    widget.onChangeText(text);
  }

  void _onTagSelected(Tag tag) {
    widget.onTagSelected(tag);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final queryText = widget.queryText;
    final tagsSuggestion = widget.tagsSuggestion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchInput(controller: _controller, onChangeText: _onChangeText, iconButton: widget.iconButton),
        const SizedBox(height: 8),

        if (queryText.isNotEmpty)
          _TagsSuggestionList(
            onTagSelected: _onTagSelected,
            tagsAsync: tagsSuggestion,
          ),
      ],
    );
  }
  //Style
  
}
class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final Widget? iconButton;
  final void Function(String value) onChangeText;

  const _SearchInput({
    required this.controller,
    required this.onChangeText,
    this.iconButton,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            icon: iconButton,
            hintText: 'Buscar notas...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      onChangeText('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: onChangeText,
        );
      },
    );
  }
}

class _TagsSuggestionList extends StatelessWidget {
  final void Function(Tag tag) onTagSelected;
  final AsyncValue<List<Tag>> tagsAsync;
  const _TagsSuggestionList({
    required this.tagsAsync,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return tagsAsync.when(
      data: _whenData,
      loading: _loading,
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _whenData(List<Tag> tags) {
    if (tags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('No se encontraron tags'),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: _listTags(tags),
    );
  }

  Widget _listTags(List<Tag> tags) {
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        for (final tag in tags)
          ListTile(
            title: Text(tag.name),
            onTap: () {
              onTagSelected(tag);
            },
          ),
      ],
    );
  }

  Widget _loading() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: CircularProgressIndicator(),
    );
  }
}
