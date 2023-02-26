import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.leading,
    this.constraints = const BoxConstraints(),
    this.controller,
    this.focusNode,
    this.onChanged,
    this.readOnly = false,
    this.initialText,
    this.prefixText,
    this.suffixText,
    this.helperText,
    this.errorText,
  });

  final Widget? leading;
  final BoxConstraints constraints;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final bool readOnly;
  final String? initialText;
  final String? prefixText;
  final String? suffixText;
  final String? helperText;
  final String? errorText;

  Widget textField() {
    if (initialText != null) controller?.text = initialText!;

    return ConstrainedBox(
      constraints: constraints,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        readOnly: readOnly,
        decoration: InputDecoration(
          icon: leading,
          prefixText: prefixText,
          suffixText: suffixText,
          helperText: helperText,
          errorText: errorText,
          errorMaxLines: 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return textField();
  }
}
