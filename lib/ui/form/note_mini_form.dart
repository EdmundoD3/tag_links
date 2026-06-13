import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/config/limit_config.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:uuid/uuid.dart';

class NoteMiniForm extends ConsumerStatefulWidget {
  final String? folderId;
  const NoteMiniForm({super.key, required this.folderId});

  @override
  ConsumerState<NoteMiniForm> createState() => _NoteMiniFormState();
}

enum _FormStatus { ok, error, loading }

class _NoteMiniFormState extends ConsumerState<NoteMiniForm> {
  final _titleCtrl = TextEditingController();
  final _textController = TextEditingController();
  
  _FormStatus? _formStatus;
  bool _isHidden = true;

  // El botón se habilita si hay título y NO estamos cargando
  bool get _canSubmit => 
      _titleCtrl.text.trim().isNotEmpty && _formStatus != _FormStatus.loading;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _formStatus == _FormStatus.loading) return;

    setState(() => _formStatus = _FormStatus.loading);
    
    final folderId = widget.folderId;
    final content = _textController.text.trim();

    try {
      final fileId = await ref
          .read(localSyncQueueRepositoryProvider)
          .getOrCreateAvailableFileId(TypeQueue.notes);

      final newNote = Note(
        id: const Uuid().v4(),
        folderId: folderId,
        fileId: fileId,
        title: title,
        content: content,
        link: null,
        tags: [],
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Guardamos la nota
      ref.read(notesProvider(folderId).notifier).addNote(newNote);

      // Éxito: Mostramos el check un momento antes de cerrar
      setState(() => _formStatus = _FormStatus.ok);
      await Future.delayed(const Duration(milliseconds: 600));
      
      _cleanForm();
    } catch (e) {
      debugPrint("_NoteMiniFormState.submit Error: $e");
      setState(() => _formStatus = _FormStatus.error);
      
      // El error lo dejamos visible un par de segundos y luego regresamos al icono de enviar
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _formStatus = null);
    }
  }

  void _cleanForm() {
    if (!mounted) return;
    _titleCtrl.clear();
    _textController.clear();
    _formStatus = null;
    setState(() => _isHidden = true);
    FocusScope.of(context).unfocus();
  }

  // --- WIDGETS DE UI ---

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _contraibleButton(),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: !_isHidden ? _whatsappStyleForm() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _whatsappStyleForm() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
          topRight: Radius.zero,
        ),
        border: Border.all(color: Colors.grey.withAlpha(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _titleTextField()),
              const SizedBox(width: 8),
              _confirmButton(),
            ],
          ),
          _sutilDivider(),
          _contentTextField(),
        ],
      ),
    );
  }

  Widget _confirmButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Material(
        key: ValueKey(_formStatus), // Importante para la animación de cambio de icono
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _canSubmit ? _submit : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _confirmIconStatus(),
          ),
        ),
      ),
    );
  }

  Widget _confirmIconStatus() {
    final theme = Theme.of(context);
    
    switch (_formStatus) {
      case _FormStatus.loading:
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.primaryColor,
          ),
        );
      case _FormStatus.ok:
        return const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24);
      case _FormStatus.error:
        return const Icon(Icons.error_outline_rounded, color: Colors.red, size: 24);
      default:
        return Icon(
          Icons.send_rounded,
          size: 22,
          color: _canSubmit ? const Color.fromARGB(255, 82, 185, 232).withAlpha(200) : Colors.grey.withAlpha(120),
        );
    }
  }

  Widget _titleTextField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _titleCtrl,
      onChanged: (_) => setState(() {}),
      maxLength: LimitAppConfig.titleMaxLength,
      maxLines: 1,
      style:  theme.textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        hintText: ref.tr(TKeys.forms.title, fallback: 'Título'),
        border: InputBorder.none,
        counterText: "",
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }

  Widget _contentTextField() {
      final theme = Theme.of(context);
    return TextField(
      controller: _textController,
      maxLines: 3,
      onChanged: (_) => setState(() {}),
      style: theme.textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        hintText: ref.tr(TKeys.forms.content, fallback: 'Contenido'),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 6),
      ),
      maxLength: LimitAppConfig.contentMaxLength,
    );
  }

  Widget _sutilDivider() {
    return Divider(height: 8, thickness: 0.5, color: Colors.grey.withAlpha(90));
  }

  Widget _contraibleButton() {
    final theme = Theme.of(context);

    // Colores dinámicos basados en tu tema
    final Color activeColor = theme.cardColor;
    final Color expandedColor = theme.appBarTheme.backgroundColor?.withAlpha(240) ?? const Color.fromARGB(255, 111, 148, 140);
    final Color? textColor = _isHidden ? theme.bottomNavigationBarTheme.selectedIconTheme?.color : Colors.white;

    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _isHidden ? activeColor : expandedColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            // Se vuelve recto abajo solo cuando el formulario está visible
            bottomLeft: _isHidden ? const Radius.circular(20) : Radius.zero,
            bottomRight: _isHidden ? const Radius.circular(20) : Radius.zero,
          ),
          boxShadow: [
            if (_isHidden)
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _isHidden = !_isHidden),
            // Mantenemos el radio superior para el feedback táctil
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: _isHidden
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono: Nota al cerrar, Flecha al abrir
                  Icon(
                    _isHidden
                        ? Icons.edit_note_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: textColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isHidden
                        ? ref.tr(
                            TKeys.forms.fastNote,
                            fallback: 'Escribe una nota...',
                          )
                        : ref.tr(
                            TKeys.forms.hiddenFastNote,
                            fallback: 'Ocultar',
                          ),
                    style: TextStyle(
                      color: _isHidden ? theme.bottomNavigationBarTheme.selectedItemColor : Colors.white,
                      fontSize: 13,
                      fontWeight: _isHidden
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}