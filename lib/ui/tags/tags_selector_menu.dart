import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/config/limit_config.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/search/search_bar.dart';
import 'package:tag_links/ui/search/tags_suggestion_list.dart';
import 'package:tag_links/ui/tags/show_create_tag_modal.dart';
import 'package:tag_links/ui/tags/tag_selected_container.dart';

class TagsSelectorMenu extends ConsumerStatefulWidget {
  final List<Tag> tags;
  final void Function(Tag tag) onTagSelected;
  final ValueChanged<Tag> onDeletedTag;
  final void Function()? onClearSave;

  const TagsSelectorMenu({
    super.key,
    required this.tags,
    required this.onTagSelected,
    required this.onDeletedTag,
    this.onClearSave,
  });

  @override
  ConsumerState<TagsSelectorMenu> createState() => _TagsSelectorMenuState();
}

class _TagsSelectorMenuState extends ConsumerState<TagsSelectorMenu> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canAddMoreTags => widget.tags.length < LimitAppConfig.maxTagsPerItem;

  void _onTagSelected(Tag tag) {
    if (!_canAddMoreTags) return;
    widget.onTagSelected(tag);
    ref.read(tagSearchTextProvider.notifier).state = '';
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final queryText = ref.watch(tagSearchTextProvider);
    final tagsSuggestion = ref.watch(tagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _canAddMoreTags ? 1.0 : 0.5,
          child: AbsorbPointer(
            absorbing: !_canAddMoreTags,
            child: SearchListBar<Tag>(
              queryText: queryText,
              enabled: _canAddMoreTags,
              focusNode: _focusNode,
              itemsSuggestion: tagsSuggestion,
              onChangeText: (text) {
                if (text.length <= LimitAppConfig.tagMaxLength) {
                  ref.read(tagSearchTextProvider.notifier).state = text;
                }
              },
              onItemSelected: _onTagSelected,
              suggestionBuilder: (context, itemsSuggestion, onItemSelected) {
                return TagsSuggestionList(
                  itemsSuggestion: itemsSuggestion,
                  onItemSelected: onItemSelected,
                );
              },
              addIconBtnCtrl: _canAddMoreTags
                  ? (tagName) async {
                      widget.onClearSave?.call();
                      final newTag = await showCreateTagModal(
                        context: context,
                        ref: ref,
                        initText: tagName,
                      );
                      if (newTag != null) _onTagSelected(newTag);
                    }
                  : null,
              counterWidget: Text(
                "${widget.tags.length}/${LimitAppConfig.maxTagsPerItem}",
                style: TextStyle(
                  fontSize: 12,
                  color: _canAddMoreTags ? Colors.black54 : Colors.orange,
                  fontWeight: _canAddMoreTags ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TagsSelectedContainer(
          tags: widget.tags,
          onDeleted: widget.onDeletedTag,
          onGetNewTag: (tag) {
            if (_canAddMoreTags) {
              widget.onClearSave?.call();
              widget.onTagSelected(tag);
            }
          },
        ),
      ],
    );
  }
}