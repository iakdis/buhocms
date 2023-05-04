import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';
import '../../navigation_button.dart';

class OpenBuildButton extends StatelessWidget {
  const OpenBuildButton({super.key, required this.isExtended});

  final bool isExtended;

  Widget button(BuildContext context) {
    return NavigationButton(
      isExtended: isExtended,
      text: Localization.appLocalizations().openBuildFolder,
      icon: Icons.folder_open,
      onTap: () => openBuildFolder(),
    );
  }

  @override
  Widget build(BuildContext context) => button(context);
}
