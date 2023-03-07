import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HugoBuildButton extends StatelessWidget {
  const HugoBuildButton({
    super.key,
    required this.isExtended,
  });

  final bool isExtended;

  Widget buildHugoSiteButton() {
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
                  Icons.web,
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
                          AppLocalizations.of(context)!.buildHugoSite,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          onTap: () => buildHugoSite(context: context),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => buildHugoSiteButton();
}
