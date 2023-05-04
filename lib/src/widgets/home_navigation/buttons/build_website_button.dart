import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:buhocms/src/widgets/navigation_button.dart';
import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';
import '../../../ssg/ssg.dart';
import '../../../utils/preferences.dart';

class BuildWebsiteButton extends StatelessWidget {
  const BuildWebsiteButton({super.key, required this.isExtended});

  final bool isExtended;

  Widget button(BuildContext context) {
    return NavigationButton(
      isExtended: isExtended,
      text: Localization.appLocalizations().buildWebsite(
          SSG.getSSGName(SSGTypes.values.byName(Preferences.getSSG()))),
      icon: Icons.web,
      onTap: () => buildWebsite(context: context),
    );
  }

  @override
  Widget build(BuildContext context) => button(context);
}
