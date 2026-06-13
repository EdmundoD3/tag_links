import 'package:flutter/material.dart';
import 'package:tag_links/config/limit_config.dart';
import 'package:tag_links/ui/style/input_style_form.dart';

class TitleFormController extends StatelessWidget {
  final TextEditingController titleCtrl;
  final String label;
  final String validatorMsg;
  final void Function()? onChange;

  const TitleFormController({
    super.key,
    required this.titleCtrl,
    required this.label,
    required this.validatorMsg,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: titleCtrl,
      maxLength: LimitAppConfig.titleMaxLength,
      decoration: InputStyleForm.inputDecoration(
        theme: theme,
        label: label,
        counterText: '',
      ),
      onChanged: (value) => onChange?.call(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validatorMsg;
        return null;
      },
    );
  }
}
