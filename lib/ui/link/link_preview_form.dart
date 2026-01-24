import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/service/link_preview_service.dart';
import 'package:tag_links/ui/link/link_preview_widget.dart';

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
    if (_preview != null && _preview!.url == trimmed && _preview!.hasMetadata) {
      return;
    }

    setState(() => _isLoading = true);

    final base = LinkPreview.create(noteId: widget.noteId, url: trimmed);

    final service = LinkPreviewService();
    final result = await service.prepareForSave(base);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _preview = result;
    });

    widget.onLinkChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _urlCtrl,
          decoration: const InputDecoration(
            labelText: 'Enlace (URL)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
            hintText: 'https://...',
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          onChanged: _onUrlChanged,
        ),
        if (_isLoading) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ] else if (_preview != null) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: LinkPreviewWidget(preview: _preview!),
          ),
        ],
      ],
    );
  }
}
