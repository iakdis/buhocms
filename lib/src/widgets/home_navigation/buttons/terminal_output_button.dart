import 'package:buhocms/src/provider/app/output_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';

class TerminalOutputButton extends StatelessWidget {
  const TerminalOutputButton({
    super.key,
    required this.isExtended,
  });

  final bool isExtended;

  Widget terminalOutputButton() {
    return Consumer<OutputProvider>(builder: (context, outputProvider, _) {
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
                    Icons.terminal,
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
                            outputProvider.showOutput
                                ? Localization.appLocalizations()
                                    .hideTerminalOutput
                                : Localization.appLocalizations()
                                    .showTerminalOutput,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            onTap: () =>
                outputProvider.setShowOutput(!outputProvider.showOutput),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) => terminalOutputButton();
}
