import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/buho_functions.dart';

class OpenServerButton extends StatelessWidget {
  const OpenServerButton({super.key, required this.isExtended});

  final bool isExtended;

  Widget openServerButton() {
    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
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
                  Icons.open_in_new,
                  size: 32.0,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                if (isExtended)
                  Row(
                    children: [
                      const SizedBox(width: 16.0),
                      SizedBox(
                        width: constraints.maxWidth - 80,
                        child: Text(
                          Localization.appLocalizations().openLiveServer,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          onTap: () => openLocalhost(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => openServerButton();
}
