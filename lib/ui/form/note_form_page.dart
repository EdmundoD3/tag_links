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
import 'package:tag_links/ui/form/form_auto_save_controller.dart';
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
  late final FormAutoSaveController<Note> _autoSave;
  late final Debouncer _debouncer;

  List<Tag> _tags = [];

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

    _debouncer = Debouncer(milliseconds: 500);
    _autoSave = FormAutoSaveController<Note>(
      hash: (n) =>
          '${n.title}|${n.content}|${n.link?.url}|${n.tags.map((t) => t.id).join(",")}|${n.isFavorite}|${n.folderId}',
      onSave: (note) async {
        final provider = notesProvider(note.folderId);

        if (widget.isPending) {
          await ref
              .read(noteMoveProvider)
              .move(note: note, toFolderId: note.folderId);
        } else {
          if (widget.isEdit) {
            await ref.read(provider.notifier).upsert(note);
          } else {
            await ref.read(provider.notifier).addNote(note);
          }
        }
      },
    );
  }

  @override
  void dispose() {
    //** último guardado, antes de limpiar todo, siempre al principio
    _debouncer.dispose();
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

  void _onUserChange() {
    _debouncer.run(() {
      final note = _captureNote();
      _autoSave.schedule(note);
    });
  }

  Future<void> _onSaveAndClose() async {
    if (!_formKey.currentState!.validate()) return;

    final note = _captureNote();

    // 🔥 guarda lo último sí o sí
    await _autoSave.flush(note);

    final adService = ref.read(adServiceProvider);

    if (ref.read(showInterstitialAdsProvider)) {
      adService.showInterstitialAd(
        onAdClosed: () {
          ref.read(interstitialAdsProvider.notifier).registerAdShown();
          if (mounted) Navigator.pop(context);
        },
      );
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloqueamos el cierre automático
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onSaveAndClose(); // Forzamos el guardado antes de salir
      },
      child: BodyForm(formKey: _formKey, appBar: _appBar(), children: _body()),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBarForm(
      title: t(ref, 'newNote', fallback: 'Nota nueva'),
      titleListenable: _titleCtrl,
      isFavorite: _isFavorite,
      onFavoriteToogle: _isFavoriteToogle,
      onSave: _onSaveAndClose,
      isSaving: _autoSave.isSaving,
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
        onChange: () => _onUserChange(),
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
        onChange: () => _onUserChange(),
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
        title: t(ref, 'moveToFolder', fallback: 'Mover'),
      ),
    ];
  }

  void _onLinkChanged(LinkPreview? linkPreview) {
    if (_linkPreview == linkPreview) return;
    setState(() {
      _linkPreview = linkPreview;
    });
    _onUserChange();
  }

  // controllers
  void _onTagSelected(Tag tag) {
    final hasSameId = _tags.any((t) => t.id == tag.id);
    if (hasSameId) return;
    setState(() {
      _tags = [..._tags, tag];
    });
    _onUserChange();
  }

  void _onDeletedTag(Tag tag) {
    setState(() {
      _tags = _tags.where((t) => t.id != tag.id).toList();
    });
    _onUserChange();
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
    _onUserChange();
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
      cursorColor: theme.appBarTheme.backgroundColor,
      style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      controller: contentCtrl,
      maxLength: NoteConfig.contentMaxLength,
      maxLines: null, // Permite que crezca infinitamente según el texto
      minLines: 10, // Altura inicial (puedes ajustarlo a tu gusto)
      keyboardType: TextInputType.multiline,
      onChanged: (_) => onChange(),
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor?.withAlpha(60),
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