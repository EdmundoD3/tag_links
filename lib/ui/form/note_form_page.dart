import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/ads/interstitial_ads_provider.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/core/media_in_coming/pending_note_provider.dart';
import 'package:tag_links/sync/sync_notifier_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/form/app_bar_form.dart';
import 'package:tag_links/ui/form/body_form.dart';
import 'package:tag_links/ui/form/content_form_controller.dart';
import 'package:tag_links/ui/form/form_auto_save_controller.dart';
import 'package:tag_links/ui/form/move_to_folder_button.dart';
import 'package:tag_links/ui/link/link_preview_form.dart';
import 'package:tag_links/ui/tags/tags_selector_menu.dart';
import 'package:tag_links/ui/form/title_form_controller.dart';
import 'package:tag_links/utils/debouncer.dart';
import 'package:uuid/uuid.dart';

class NoteFormPage extends ConsumerStatefulWidget {
  final Note? note;
  final String? folderId;
  final String fileId;
  final bool isPending;

  const NoteFormPage({
    super.key,
    this.note,
    required this.folderId,
    required this.fileId,
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

  // getters
  NotesNotifier get _notesProvider =>
      ref.read(notesProvider(widget.folderId).notifier);

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
        if (widget.isPending) {
          await ref
              .read(noteMoveProvider)
              .move(note: note, toFolderId: note.folderId);
        } else {
          if (widget.isEdit) {
            await _notesProvider.upsert(note);
          } else {
            await _notesProvider.addNote(note);
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
    final now = DateTime.now().millisecondsSinceEpoch;

    final link = _linkPreview;

    final note = Note(
      id: _id,
      folderId: widget.folderId,
      fileId: widget.fileId,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      link: link,
      tags: _tags,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      isFavorite: _isFavorite,
      color: widget.note?.color, //cambiar cuando se pueda agregar colores
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

    _debouncer.flush();
    final note = _captureNote();

    try {
      // Pon un timeout o asegúrate de que el flush no sea eterno
      // Si tu FormAutoSaveController es de los que se quedan esperando,
      // es mejor forzar el guardado final directamente aquí:
      if (widget.isEdit) {
        await _notesProvider.upsert(note);
      } else {
        await _notesProvider.addNote(note);
      }
    } catch (e) {
      debugPrint("Error en guardado final: $e");
    }

    unawaited(ref.read(syncProvider.notifier).synchronize(
      delay: const Duration(minutes: 1, seconds: 10)
    ));

    // Continuar con los anuncios y cerrar...
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

  // -----------build-----------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloqueamos el cierre automático
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final note = _captureNote();

        // Si NO es válida → preguntar
        if (!_isNoteValid(note)) {
          final discard = await ConfirmDialog.discardForm(context, ref);

          if (discard == true && context.mounted) {
            _notesProvider.deleteNote(note); //si descarta se elimina
            Navigator.pop(context);
          }
          return;
        }

        // Si es válida → guardar normal
        await _onSaveAndClose();
      },
      child: BodyForm(formKey: _formKey, appBar: _appBar(), children: _body()),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBarForm(
      title: ref.tr(TKeys.forms.newNote, fallback: 'Nota nueva'),
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
        label: ref.tr(TKeys.forms.title, fallback: 'Título'),
        validatorMsg: ref.tr(
          TKeys.forms.folderNameRequired,
          fallback: 'El título es obligatorio',
        ),
        onChange: () => _onUserChange(),
      ),
      const SizedBox(height: 8),
      ContentController(
        contentCtrl: _contentCtrl,
        label: ref.tr(TKeys.forms.content, fallback: 'Contenido'),
        onChange: () => _onUserChange(),
      ),
      const SizedBox(height: 8),
      LinkPreviewForm(
        noteId: _id,
        initialLink: _linkPreview,
        onLinkChanged: _onLinkChanged,
      ),
      const SizedBox(height: 16),
      TagsSelectorMenu(
        tags: _tags,
        onTagSelected: _onTagSelected,
        onDeletedTag: _onDeletedTag,
        onClearSave: _onClearSave,
      ),
      const SizedBox(height: 8),
      MoveToFolderButton(
        onChangeFolder: _onChangeFolder,
        title: ref.tr(TKeys.forms.moveToFolder, fallback: 'Mover'),
      ),
    ];
  }

  void _onClearSave() {
    debugPrint("📥 Forzando guardado de nota antes de gestionar Tags");
    _debouncer
        .flush(); // En lugar de dispose(), usamos flush para no perder cambios previos
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

    // ⚡ FORZAMOS EL GUARDADO INMEDIATO
    _forceImmediateSave();
  }

  void _onDeletedTag(Tag tag) {
    setState(() {
      _tags = _tags.where((t) => t.id != tag.id).toList();
    });

    // ⚡ FORZAMOS EL GUARDADO INMEDIATO
    _forceImmediateSave();
  }

  void _forceImmediateSave() async {
    _debouncer.dispose();
    final note = _captureNote();

    try {
      // 1. Guardado directo al Provider (Salta el debounce)
      if (widget.isEdit) {
        await _notesProvider.upsert(note);
      } else {
        await _notesProvider.addNote(note);
      }

      // 2. Avisamos al AutoSave que ya terminamos
      _autoSave.sync(note);

      // Forzamos actualización visual de la UI (para quitar el círculo si existía)
      setState(() {});
    } catch (e) {
      debugPrint("Error guardando Tag: $e");
    }
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

  // ------- validates ----------
  bool _isNoteValid(Note note) {
    return note.title.trim().isNotEmpty;
  }
}

