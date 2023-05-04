import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/buho_functions.dart';
import '../../navigation_button.dart';

class OpenServerButton extends StatelessWidget {
  const OpenServerButton({super.key, required this.isExtended});

  final bool isExtended;

  Widget button(BuildContext context) {
    return NavigationButton(
      isExtended: isExtended,
      text: Localization.appLocalizations().openLiveServer,
      icon: Icons.open_in_new,
      onTap: () => openLocalhost(),
    );
  }

  @override
  Widget build(BuildContext context) => button(context);
}
