import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/buho_functions.dart';

class CreateNewButton extends StatelessWidget {
  const CreateNewButton({
    super.key,
    required this.mounted,
    required this.isExtended,
  });

  final bool mounted;
  final bool isExtended;

  Widget createNewButton() {
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
                  Icons.add_box,
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
                          Localization.appLocalizations()
                              .newPost
                              .replaceAll('', '\u{200B}'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          onTap: () => addFile(context: context, mounted: mounted),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => createNewButton();
}
