import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/ui/text/empty_tags_text.dart';

class SearchListBar extends StatefulWidget {
  final String queryText;
  final AsyncValue<List<Tag>> tagsSuggestion;
  final void Function(String text) onChangeText;
  final void Function(Tag tag) onTagSelected;
  final Widget? iconLeftBtn;
  final Function(String text)? addIconBtnCtrl;
  const SearchListBar({
    super.key,
    required this.queryText,
    required this.tagsSuggestion,
    required this.onChangeText,
    required this.onTagSelected,
    this.iconLeftBtn,
    this.addIconBtnCtrl,
  });

  @override
  State<SearchListBar> createState() => _SearchListBarState();
}

class _SearchListBarState extends State<SearchListBar> {
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
  void didUpdateWidget(covariant SearchListBar oldWidget) {
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
        _SearchInput(
          controller: _controller,
          onChangeText: _onChangeText,
          iconLeftButton: widget.iconLeftBtn,
          sufixRightIconBtnCtrl: widget.addIconBtnCtrl,
        ),
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

class _SearchInput extends ConsumerWidget {
  final TextEditingController controller;
  final Widget? iconLeftButton;
  final void Function(String text)? sufixRightIconBtnCtrl;
  final void Function(String value) onChangeText;

  const _SearchInput({
    required this.controller,
    required this.onChangeText,
    this.iconLeftButton,
    required this.sufixRightIconBtnCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, _) {
        return TextField(
          cursorColor: theme.appBarTheme.backgroundColor,
          controller: controller,
          decoration: InputDecoration(
            fillColor: theme.inputDecorationTheme.fillColor,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: theme.focusColor, width: 2),
            ),
            filled: true,
            icon: iconLeftButton,
            hintText: ref.tr(TKeys.ui.searchHint, fallback: 'Buscar...'),
            hintStyle: TextStyle(color: theme.textTheme.labelSmall?.color),
            prefixIcon: Icon(Icons.search, color: theme.hintColor),
            suffixIcon: value.text.isNotEmpty ? _sufixIcon(theme, value) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChangeText,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        );
      },
    );
  }

  Widget _sufixIcon(ThemeData theme, TextEditingValue value) {
    final iconColor = theme.hintColor;
    return Row(
      mainAxisSize:
          MainAxisSize.min, // <--- CRUCIAL: Esto evita que el Row se expanda
      children: [
        IconButton(
          visualDensity:
              VisualDensity.compact, // Reduce el padding interno del botón
          icon: Icon(Icons.clear, color: iconColor),
          onPressed: () {
            controller.clear();
            onChangeText('');
          },
        ),
        if (sufixRightIconBtnCtrl != null)
          IconButton(
            visualDensity:
                VisualDensity.compact, // Reduce el padding interno del botón
            icon: Icon(Icons.add, color: iconColor),
            onPressed: () {
              sufixRightIconBtnCtrl!(value.text);
              controller.clear();
              onChangeText('');
            },
          ),
        const SizedBox(width: 8), // Un pequeño margen al final
      ],
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
      error: (e, _) {
        debugPrint('_TagsSuggestionList.build Error: $e');
        return const Text('Error: Tags');
      },
    );
  }

  Widget _whenData(List<Tag> tags) {
    if (tags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: EmptyTagsText(),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: Builder(builder: (context) => _listTags(tags, context)),
    );
  }

  Widget _listTags(List<Tag> tags, BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        for (final tag in tags)
          ListTile(
            title: Text(
              tag.name,
              style: TextStyle(color: theme.textTheme.labelSmall?.color),
            ),
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
