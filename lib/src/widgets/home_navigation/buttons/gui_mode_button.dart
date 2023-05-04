import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/buho_functions.dart';
import '../../../provider/editing/editing_provider.dart';
import '../../navigation_button.dart';

class GUIModeButton extends StatelessWidget {
  const GUIModeButton({
    super.key,
    required this.isExtended,
    required this.isGUIMode,
  });

  final bool isGUIMode;
  final bool isExtended;

  Widget button(BuildContext context) {
    return Consumer<EditingProvider>(builder: (context, editingProvider, _) {
      return NavigationButton(
        isExtended: isExtended,
        text: isGUIMode
            ? Localization.appLocalizations().guiMode
            : Localization.appLocalizations().textMode,
        icon: isGUIMode ? Icons.table_chart : Icons.text_snippet_outlined,
        onTap: editingProvider.isGUIMode == isGUIMode
            ? null
            : () => setGUIMode(
                  context: context,
                  isGUIMode: isGUIMode,
                ),
        iconColor: isGUIMode == editingProvider.isGUIMode
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.onPrimary,
        textStyle: TextStyle(
            color: isGUIMode == editingProvider.isGUIMode
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.onPrimary),
      );
    });
  }

  @override
  Widget build(BuildContext context) => button(context);
}
