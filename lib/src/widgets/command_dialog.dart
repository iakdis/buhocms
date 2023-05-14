import 'package:flutter/material.dart';

import '../i18n/l10n.dart';

class CommandDialog extends StatefulWidget {
  const CommandDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.expansionIcon,
    required this.expansionTitle,
    required this.yes,
    required this.dialogChildren,
    required this.expansionChildren,
    this.progressIndicator,
    this.disableNavigation = false,
  });

  final Widget title;
  final IconData icon;
  final IconData expansionIcon;
  final String expansionTitle;
  final Function? yes;
  final List<Widget> dialogChildren;
  final List<Widget>? expansionChildren;
  final Widget? progressIndicator;
  final bool disableNavigation;

  @override
  State<CommandDialog> createState() => _CommandDialogState();
}

class _CommandDialogState extends State<CommandDialog> {
  Widget commandDialog() {
    return SimpleDialog(
      contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
      children: [
        Column(
          children: [
            Icon(widget.icon, size: 64.0),
            const SizedBox(height: 16.0),
            widget.title,
          ],
        ),
        const SizedBox(height: 32.0),
        Column(children: widget.dialogChildren),
        if (widget.expansionChildren != null) const SizedBox(height: 16.0),
        if (widget.expansionChildren != null)
          ExpansionTile(
            maintainState: true,
            leading: Icon(widget.expansionIcon),
            title: Text(widget.expansionTitle),
            expandedAlignment: Alignment.topLeft,
            childrenPadding: const EdgeInsets.only(top: 8.0),
            children: widget.expansionChildren!,
          ),
        if (widget.progressIndicator != null) const SizedBox(height: 32),
        Center(child: widget.progressIndicator),
        const SizedBox(height: 64),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.disableNavigation
                  ? null
                  : () => Navigator.pop(context),
              child: Text(Localization.appLocalizations().cancel),
            ),
            TextButton(
              onPressed:
                  widget.disableNavigation ? null : () => widget.yes?.call(),
              child: Text(Localization.appLocalizations().yes),
            ),
          ],
        ),
      ],
    );
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
