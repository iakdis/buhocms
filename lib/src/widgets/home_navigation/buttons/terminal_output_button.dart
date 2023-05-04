import 'package:buhocms/src/provider/app/output_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';
import '../../navigation_button.dart';

class TerminalOutputButton extends StatelessWidget {
  const TerminalOutputButton({
    super.key,
    required this.isExtended,
  });

  final bool isExtended;

  Widget button(BuildContext context) {
    return Consumer<OutputProvider>(builder: (context, outputProvider, _) {
      return NavigationButton(
        isExtended: isExtended,
        text: outputProvider.showOutput
            ? Localization.appLocalizations().hideTerminalOutput
            : Localization.appLocalizations().showTerminalOutput,
        icon: Icons.terminal,
        onTap: () => outputProvider.setShowOutput(!outputProvider.showOutput),
      );
    });
  }

  @override
  Widget build(BuildContext context) => button(context);
}
