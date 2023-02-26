import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommandDialog extends StatelessWidget {
  const CommandDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.expansionIcon,
    required this.expansionTitle,
    required this.yes,
    required this.children,
  });

  final Widget title;
  final IconData icon;
  final IconData expansionIcon;
  final String expansionTitle;
  final Function yes;
  final List<Widget> children;

  Widget commandDialog() {
    return LayoutBuilder(builder: (context, constraints) {
      return StatefulBuilder(builder: (context, setState) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
          children: [
            Column(
              children: [
                Icon(icon, size: 64.0),
                const SizedBox(height: 16.0),
                title,
              ],
            ),
            const SizedBox(height: 32.0),
            ExpansionTile(
              leading: Icon(expansionIcon),
              title: Text(expansionTitle),
              expandedAlignment: Alignment.topLeft,
              children: children,
            ),
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => yes(),
                  child: Text(AppLocalizations.of(context)!.yes),
                ),
              ],
            ),
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) => commandDialog();
}

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
  Widget build(BuildContext context) => textField();
}
