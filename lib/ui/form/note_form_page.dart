import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/ads/interstitial_ads_provider.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/state/pending_note_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/form/app_bar_form.dart';
import 'package:tag_links/ui/form/body_form.dart';
import 'package:tag_links/ui/form/move_to_folder_button.dart';
import 'package:tag_links/ui/link/link_preview_form.dart';
import 'package:tag_links/ui/tags/tags_selector_menu.dart';
import 'package:tag_links/ui/form/title_form_controller.dart';
import 'package:tag_links/utils/debouncer.dart';
import 'package:uuid/uuid.dart';

class NoteFormPage extends ConsumerStatefulWidget {
  final Note? note;
  final String folderId;
  final bool isPending;

  const NoteFormPage({
    super.key,
    this.note,
    required this.folderId,
    this.isPending = false,
  });

  bool get isEdit => note != null;

  @override
  ConsumerState<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends ConsumerState<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late final Debouncer _saveDebouncer;
  bool _isSaving = false;
  List<Tag> _tags = [];

  String? _lastSavedHash;

  String _noteHash(Note n) {
    return '${n.title}|${n.content}|${n.link?.url}|${n.tags.map((t) => t.id).join(",")}|${n.isFavorite}|${n.folderId}';
  }

  bool _isFavorite = false;
  LinkPreview? _linkPreview;
  String _id = '';

  @override
  void initState() {
    super.initState();
    _tags = widget.note?.tags ?? [];
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _isFavorite = widget.note?.isFavorite ?? false;
    _linkPreview = widget.note?.link;
    _id = widget.note?.id ?? const Uuid().v4();
    _saveDebouncer = Debouncer(milliseconds: 800);
  }

  @override
  void dispose() {
    //** último guardado, antes de limpiar todo, siempre al principio
    _saveDebouncer.dispose();
    //**
    _titleCtrl.dispose();
    _contentCtrl.dispose();

    super.dispose();
  }

  Note _captureNote() {
    final now = DateTime.now();

    final link = _linkPreview;

    final note = Note(
      id: _id,
      folderId: widget.folderId,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      link: link,
      tags: _tags,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      isFavorite: _isFavorite,
    );
    return note;
  }

  Future<void> _onSave() async {
    final note = _captureNote();

    final hash = _noteHash(note);
    if (_lastSavedHash == hash) return;

    // Lógica de guardado
    if (widget.isPending) {
      await ref
          .read(noteMoveProvider)
          .move(note: note, toFolderId: widget.folderId);
    } else {
      final provider = notesProvider(widget.folderId);

      if (widget.isEdit) {
        await ref.read(provider.notifier).updateNote(note);
      } else {
        await ref.read(provider.notifier).addNote(note);
      }
    }

    _lastSavedHash = hash;
  }

  Future<void> _autoSave() async {
    if (_isSaving) return;
    if (_formKey.currentState == null) return;
    if (!_formKey.currentState!.validate()) return;

    _isSaving = true;

    try {
      await _onSave();
    } catch (e) {
      debugPrint('Error al guardar: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      } else {
        _isSaving = false;
      }
    }
  }

  Future<void> _onSaveAndClose() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _onSave();
      // Lógica de Anuncios
      final adService = ref.read(adServiceProvider);
      final tocaIntersticial = ref.read(showInterstitialAdsProvider);
      if (tocaIntersticial) {
        adService.showInterstitialAd(
          onAdClosed: () {
            ref.read(interstitialAdsProvider.notifier).registerAdShown();
            if (mounted) Navigator.pop(context);
          },
        );
        // Importante: No ponemos _isSaving = false aquí porque vamos a cerrar la pantalla.
        return;
      }

      // Si NO toca anuncio, cerramos normalmente
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Si algo falla (ej. error de red al guardar), reactivamos el botón
      if (mounted) setState(() => _isSaving = false);
      // Aquí podrías mostrar un SnackBar de error
    }
  }

  @override
  Widget build(BuildContext context) {
    return BodyForm(formKey: _formKey, appBar: _appBar(), children: _body());
  }

  PreferredSizeWidget _appBar() {
    return AppBarForm(
      title: widget.isEdit ? _titleCtrl.text : 'Nueva nota',
      isFavorite: _isFavorite,
      onFavoriteToogle: _isFavoriteToogle,
      onSave: _onSaveAndClose,
      isSaving: _isSaving,
    );
  }

  List<Widget> _body() {
    return [
      TitleFormController(
        titleCtrl: _titleCtrl,
        label: t(ref, 'title', fallback: 'Título'),
        validatorMsg: t(
          ref,
          'titleRequired',
          fallback: 'El título es obligatorio',
        ),
        onChange: () => _saveDebouncer.run(_autoSave),
      ),
      const SizedBox(height: 16),
      LinkPreviewForm(
        noteId: _id,
        initialLink: _linkPreview,
        onLinkChanged: _onLinkChanged,
      ),
      const SizedBox(height: 16),
      _ContentController(
        contentCtrl: _contentCtrl,
        label: t(ref, 'content', fallback: 'Contenido'),
        onChange: () => _saveDebouncer.run(_autoSave),
      ),
      const SizedBox(height: 16),
      TagsSelectorMenu(
        tags: _tags,
        onTagSelected: _onTagSelected,
        onDeletedTag: _onDeletedTag,
      ),
      const SizedBox(height: 8),
      MoveToFolderButton(
        onChangeFolder: _onChangeFolder,
        title: t(ref, 'moveToFolder', fallback: 'Cambiar carpeta'),
      ),
    ];
  }

  void _onLinkChanged(LinkPreview? linkPreview) {
    if (_linkPreview == linkPreview) return;
    setState(() {
      _linkPreview = linkPreview;
    });
    _saveDebouncer.run(_autoSave);
  }

  // controllers
  void _onTagSelected(Tag tag) {
    if (_tags.any((t) => t.id == tag.id)) return;

    setState(() {
      _tags = [..._tags, tag];
    });
    _saveDebouncer.run(_autoSave);
  }

  void _onDeletedTag(Tag tag) {
    setState(() {
      _tags = _tags.where((t) => t.id != tag.id).toList();
    });
    _saveDebouncer.run(_autoSave);
  }

  Future<void> _onChangeFolder() async {
    final isConfirm = await ConfirmDialog.moveNote(context, ref);

    if (isConfirm != true) return;

    final note = _captureNote();
    ref.read(pendingNoteProvider.notifier).set(note, TypeMove.move);

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _isFavoriteToogle() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _saveDebouncer.run(_autoSave);
  }
}

class _ContentController extends StatelessWidget {
  final TextEditingController contentCtrl;
  final String label;
  final VoidCallback onChange;
  const _ContentController({
    required this.contentCtrl,
    required this.label,
    required this.onChange,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      controller: contentCtrl,
      maxLength: NoteConfig.contentMaxLength,
      onChanged: (_) => onChange(),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: theme.hintColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.focusColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.focusColor, width: 2),
        ),
      ),
    );
  }
}
