import 'package:buhocms/src/pages/editing_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../logic/buho_functions.dart';
import '../../../provider/editing/editing_provider.dart';

class GUIModeButton extends StatelessWidget {
  const GUIModeButton({
    super.key,
    required this.isExtended,
    required this.isGUIMode,
    required this.editingPageKey,
  });

  final GlobalKey<EditingPageState> editingPageKey;
  final bool isGUIMode;
  final bool isExtended;

  Widget _guiModeButton() {
    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        color: Colors.transparent,
        child:
            Consumer<EditingProvider>(builder: (context, editingProvider, _) {
          return InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: editingProvider.isGUIMode == isGUIMode
                ? null
                : () => setGUIMode(
                      context: context,
                      editingPageKey: editingPageKey,
                      isGUIMode: isGUIMode,
                    ),
            child: Padding(
              padding: isExtended
                  ? const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0)
                  : const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: isExtended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Icon(
                    //index == this.index ? icon : iconUnselected,
                    isGUIMode
                        ? Icons.table_chart //Icons.view_module_sharp
                        : Icons.text_snippet_outlined,
                    size: 32.0,
                    color: isGUIMode == editingProvider.isGUIMode
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                  isExtended
                      ? Row(
                          children: [
                            const SizedBox(
                              width: 16.0,
                            ),
                            SizedBox(
                              width: constraints.maxWidth - 80,
                              child: Text(
                                isGUIMode
                                    ? AppLocalizations.of(context)!.guiMode
                                    : AppLocalizations.of(context)!.textMode,
                                style: TextStyle(
                                    color:
                                        isGUIMode == editingProvider.isGUIMode
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ), //this.index = index),
          );
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _guiModeButton();
  }
}
