import 'package:flutter/material.dart';

Future<T?> showAppModal<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: child,
        ),
      );
    },
  );
}

class ModalTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const ModalTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              color: theme.textTheme.labelMedium?.color,
            ),
          ),
        ),

        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class ModalActions extends StatelessWidget {
  final Widget leading;
  final Widget trailing;

  const ModalActions({
    super.key,
    required this.leading,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        const Spacer(),
        trailing,
      ],
    );
  }
}