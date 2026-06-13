import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tag_links/core/decorate_color/color_picker.dart';
import 'package:tag_links/core/decorate_color/decorated_color_themes.dart';

class AppBarForm extends StatelessWidget implements PreferredSizeWidget {
  final bool isFavorite;
  final String title;
  final void Function() onFavoriteToogle;
  final void Function() onSave;
  final List<Widget>? actions;
  final bool isSaving;
  final ValueListenable<TextEditingValue>? titleListenable;
  final DecorateColor? decorateColor;
  final void Function(String?) colorChange;

  const AppBarForm({
    super.key,
    required this.title,
    this.actions,
    required this.onSave,
    required this.isFavorite,
    required this.onFavoriteToogle,
    required this.isSaving,
    this.titleListenable,
    required this.decorateColor,
    required this.colorChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget titleWidget;

    if (titleListenable != null) {
      titleWidget = ValueListenableBuilder<TextEditingValue>(
        valueListenable: titleListenable!,
        builder: (_, value, _) {
          return Text(value.text);
        },
      );
    } else {
      titleWidget = Text(title);
    }
    final highlight = theme.textTheme.labelMedium?.color;
    return AppBar(
      title: titleWidget,
      actions: [
        ColorPickerAppBarButton(
          selectedColor: decorateColor?.code,
          onChanged: colorChange,
        ),
        IconButton(
          onPressed: onFavoriteToogle,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : theme.appBarTheme.foregroundColor,
          ),
        ),
        IconButton(
          icon: isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: highlight,
                  ),
                )
              : Icon(Icons.save, color: highlight ?? theme.iconTheme.color),
          onPressed: onSave,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
