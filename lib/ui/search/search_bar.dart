import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';

/// usar en el Scaffold onTap: () => FocusScope.of(context).unfocus(), si es que se usa este buscador
class SearchListBar<T> extends StatefulWidget {
  final String queryText;
  final AsyncValue<List<T>> itemsSuggestion;
  final void Function(String text) onChangeText;
  final void Function(T item) onTagSelected;
  final Widget? iconLeftBtn;
  final Function(String text)? addIconBtnCtrl;
  final SuggestionListBuilder<T> suggestionBuilder;

  const SearchListBar({
    super.key,
    required this.queryText,
    required this.itemsSuggestion,
    required this.onChangeText,
    required this.onTagSelected,
    this.iconLeftBtn,
    this.addIconBtnCtrl,
    required this.suggestionBuilder,
  });

  @override
  State<SearchListBar<T>> createState() => _SearchListBarState<T>();
}

class _SearchListBarState<T> extends State<SearchListBar<T>> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode; // <--- Nuevo
  bool _isFocused = false; // <--- Nuevo para trackear el estado

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.queryText);
    _focusNode = FocusNode();

    // Escuchamos los cambios de foco
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SearchListBar<T> oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final queryText = widget.queryText;

    // Nueva lógica: Mostrar si hay texto O si el widget tiene el foco activo
    final bool showSuggestions = queryText.isNotEmpty || _isFocused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchInput(
          controller: _controller,
          focusNode: _focusNode, // <--- Pasamos el focusNode
          onChangeText: _onChangeText,
          iconLeftButton: widget.iconLeftBtn,
          sufixRightIconBtnCtrl: widget.addIconBtnCtrl,
        ),
        const SizedBox(height: 8),
        if (showSuggestions)
          widget.suggestionBuilder,
      ],
    );
  }
}

class _SearchInput extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode; // <--- Nuevo
  final Widget? iconLeftButton;
  final void Function(String text)? sufixRightIconBtnCtrl;
  final void Function(String value) onChangeText;

  const _SearchInput({
    required this.controller,
    required this.focusNode, // <--- Requerido
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
          controller: controller,
          focusNode: focusNode, // <--- Vinculación clave
          cursorColor: theme.appBarTheme.backgroundColor,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.clear, color: iconColor),
          onPressed: () {
            controller.clear();
            onChangeText('');
          },
        ),
        if (sufixRightIconBtnCtrl != null)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.add, color: iconColor),
            onPressed: () {
              sufixRightIconBtnCtrl!(value.text);
              controller.clear();
              onChangeText('');
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}
abstract class SuggestionListBuilder<T> extends StatelessWidget {
  final AsyncValue<List<T>> itemsSuggestion;
  final void Function(T item) onItemSelected;

  const SuggestionListBuilder({
    super.key,
    required this.itemsSuggestion,
    required this.onItemSelected,
  });
}
