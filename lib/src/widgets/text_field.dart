import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.leading,
    this.constraints = const BoxConstraints(),
    this.controller,
    this.focusNode,
    this.onChanged,
    this.prefixText,
    this.suffixText,
    this.hintText,
    this.errorText,
  });

  final Widget? leading;
  final BoxConstraints constraints;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final String? prefixText;
  final String? suffixText;
  final String? hintText;
  final String? errorText;

  Widget textField() {
    return ConstrainedBox(
      constraints: constraints,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: leading,
          prefixText: prefixText,
          suffixText: suffixText,
          hintText: hintText,
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
