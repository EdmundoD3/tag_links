import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';

/// Widget de búsqueda con lista de sugerencias.
///
/// Usar en el Scaffold:
/// ```dart
/// onTap: () => FocusScope.of(context).unfocus(),
/// ```
class SearchListBar<T> extends StatefulWidget {
  final String queryText;
  final AsyncValue<List<T>> itemsSuggestion;
  final void Function(String text) onChangeText;
  final void Function(T item) onItemSelected;
  final Widget? iconLeftBtn;
  final Function(String text)? addIconBtnCtrl;
  final Widget? counterWidget;
  final bool enabled;
  final FocusNode focusNode;
  final String hintText;

  /// Builder para renderizar la lista de sugerencias.
  final Widget Function(
    BuildContext context,
    AsyncValue<List<T>> itemsSuggestion,
    void Function(T item) onItemSelected,
  ) suggestionBuilder;

  const SearchListBar({
    super.key,
    required this.queryText,
    required this.itemsSuggestion,
    required this.onChangeText,
    required this.onItemSelected,
    this.iconLeftBtn,
    this.addIconBtnCtrl,
    required this.suggestionBuilder,
    this.counterWidget,
    this.enabled = true,
    required this.focusNode, required this.hintText,
  });

  @override
  State<SearchListBar<T>> createState() => _SearchListBarState<T>();
}

class _SearchListBarState<T> extends State<SearchListBar<T>> {
  late final TextEditingController _controller;
  FocusNode? _oldFocusNode;

  /// 🆕 Solo true cuando el usuario enfocó explícitamente (tocando el campo)
  bool _userFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.queryText);
    _attachFocusNodeListener();
  }

  void _attachFocusNodeListener() {
    widget.focusNode.addListener(_onFocusChange);
    _oldFocusNode = widget.focusNode;
  }

  void _detachFocusNodeListener() {
    _oldFocusNode?.removeListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant SearchListBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sincronizar queryText externo
    if (widget.queryText != oldWidget.queryText &&
        widget.queryText != _controller.text) {
      _controller.text = widget.queryText;
    }

    // Manejar cambio de FocusNode (evita memory leak)
    if (widget.focusNode != oldWidget.focusNode) {
      _detachFocusNodeListener();
      _attachFocusNodeListener();
    }

    // Mover cursor al final solo cuando el foco cambia a true
    if (widget.focusNode.hasFocus &&
        !oldWidget.focusNode.hasFocus &&
        _controller.selection.baseOffset != _controller.text.length) {
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _detachFocusNodeListener();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;

    // 🆕 Si pierde el foco, reseteamos _userFocused
    if (!widget.focusNode.hasFocus) {
      _userFocused = false;
    }

    setState(() {});
  }

  void _onChangeText(String text) {
    widget.onChangeText(text);
  }

  /// 🆕 Se llama cuando el usuario toca el campo (no cuando Flutter restaura foco)
  void _onTapField() {
    _userFocused = true;
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final queryText = widget.queryText;

    // 🆕 Mostrar sugerencias si:
    // 1. Hay texto escrito, O
    // 2. El usuario tocó explícitamente el campo (foco + _userFocused)
    final showSuggestions = queryText.isNotEmpty || 
        (widget.focusNode.hasFocus && _userFocused);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchInput(
          controller: _controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          onChangeText: _onChangeText,
          onTapField: _onTapField, // 🆕
          iconLeftButton: widget.iconLeftBtn,
          suffixRightIconBtnCtrl: widget.addIconBtnCtrl,
          counterWidget: widget.counterWidget,
          hintText: widget.hintText,
        ),
        const SizedBox(height: 8),
        if (showSuggestions)
          widget.suggestionBuilder(
            context,
            widget.itemsSuggestion,
            widget.onItemSelected,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Widget interno del input
// ---------------------------------------------------------------------------

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Widget? iconLeftButton;
  final void Function(String text)? suffixRightIconBtnCtrl;
  final void Function(String value) onChangeText;
  final VoidCallback onTapField; // 🆕
  final Widget? counterWidget;
  final bool enabled;
  final String hintText;

  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.onChangeText,
    required this.onTapField, // 🆕
    this.iconLeftButton,
    required this.suffixRightIconBtnCtrl,
    required this.enabled,
    this.counterWidget, required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        return TextField(
          enabled: enabled,
          controller: controller,
          autofocus: false,
          showCursor: true,
          focusNode: focusNode,
          cursorColor: theme.appBarTheme.backgroundColor,
          decoration: InputDecoration(
            fillColor: theme.inputDecorationTheme.fillColor,
            counter: counterWidget,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: theme.focusColor, width: 2),
            ),
            filled: true,
            icon: iconLeftButton,
            hintText: hintText,
            hintStyle: TextStyle(color: theme.textTheme.labelSmall?.color),
            prefixIcon: Icon(Icons.search, color: theme.hintColor),
            suffixIcon: value.text.isNotEmpty ? _suffixIcon(theme, value) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChangeText,
          onTap: onTapField, // 🆕 Solo el tap del usuario activa _userFocused
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        );
      },
    );
  }

  Widget _suffixIcon(ThemeData theme, TextEditingValue value) {
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
        if (suffixRightIconBtnCtrl != null)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.add, color: iconColor),
            onPressed: () {
              suffixRightIconBtnCtrl!(value.text);
              controller.clear();
              onChangeText('');
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Extension helper para traducción (ajusta según tu proyecto)
// ---------------------------------------------------------------------------

extension BuildContextTr on BuildContext {
  String tr(String key, {String? fallback}) {
    return fallback ?? key;
  }
}