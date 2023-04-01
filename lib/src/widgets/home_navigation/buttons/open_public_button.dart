import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';

class OpenPublicButton extends StatelessWidget {
  const OpenPublicButton({
    super.key,
    required this.isExtended,
  });

  final bool isExtended;

  Widget openLocalhostButton() {
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
                    Icons.folder_open,
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
                            Localization.appLocalizations().openPublicFolder,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            onTap: () => openHugoPublicFolder()),
      );
    });
  }

  @override
  Widget build(BuildContext context) => openLocalhostButton();
}
