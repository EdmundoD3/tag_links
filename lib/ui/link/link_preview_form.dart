import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tag_links/config/limit_config.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/service/link_preview_service.dart';
import 'package:tag_links/ui/link/link_preview_widget.dart';
import 'package:tag_links/ui/style/input_style_form.dart';

class LinkPreviewForm extends StatefulWidget {
  final String noteId;
  final LinkPreview? initialLink;
  final ValueChanged<LinkPreview?> onLinkChanged;

  const LinkPreviewForm({
    super.key,
    required this.noteId,
    this.initialLink,
    required this.onLinkChanged,
  });

  @override
  State<LinkPreviewForm> createState() => _LinkPreviewFormState();
}

class _LinkPreviewFormState extends State<LinkPreviewForm> {
  Timer? _debounce;
  late TextEditingController _urlCtrl;

  LinkPreview? _preview;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preview = widget.initialLink;
    _urlCtrl = TextEditingController(text: _preview?.url ?? '');
    if (_preview?.url != null) _fetchPreview(_preview!.url);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _onUrlChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () {
      _fetchPreview(value);
    });
  }

  Future<void> _fetchPreview(String url) async {
    final trimmed = url.trim();

    // 🔹 Nada escrito → limpiar preview
    if (trimmed.isEmpty) {
      if (_preview != null) {
        setState(() => _preview = null);
        widget.onLinkChanged(null);
      }
      return;
    }

    // 🔹 Muy corto para ser una URL real
    if (trimmed.length < 8) {
      return;
    }

    // 🔹 Mismo link y ya tiene metadata → no refetch
    if (_preview != null && _preview!.url == trimmed && _preview!.hasThumbnail) {
      return;
    }

    setState(() => _isLoading = true);

    final base = LinkPreview.create(noteId: widget.noteId, url: trimmed);

    final result = await LinkPreviewService.prepareForSave(base);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _preview = result;
    });

    widget.onLinkChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 15,
          ),
          controller: _urlCtrl,
          maxLength: LimitAppConfig.urlMaxLength,
          maxLines: 1, // Las URLs suelen ser de una sola línea
          decoration: InputStyleForm.inputDecoration(
            theme: theme,
            label: 'URL',
            counterText: '',
          ).copyWith(hintText: 'https://...', hintStyle: TextStyle(color: theme.hintColor)),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          onChanged: _onUrlChanged,
        ),
        if (_isLoading) ...[
          const SizedBox(height: 16),
          // Un indicador de progreso más fino y elegante
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              backgroundColor: theme.colorScheme.primary.withAlpha(30),
              color: theme.colorScheme.primary.withAlpha(200),
              minHeight: 4,
            ),
          ),
        ] else if (_preview != null) ...[
          const SizedBox(height: 16),
          // Card de previsualización mejorada
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: theme.dividerColor.withAlpha(30)),
            ),
            padding: const EdgeInsets.all(
              4,
            ), // Espacio interno para que el widget respire
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinkPreviewWidget(preview: _preview!),
            ),
          ),
        ],
      ],
    );
  }
}
