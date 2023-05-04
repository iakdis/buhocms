import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/buho_functions.dart';
import '../../../ssg/ssg.dart';
import '../../navigation_button.dart';

class LiveServerButton extends StatelessWidget {
  const LiveServerButton({super.key, required this.isExtended});

  final bool isExtended;

  Widget button(BuildContext context) {
    return Consumer<ShellProvider>(builder: (context, shellProvider, _) {
      return NavigationButton(
        isExtended: isExtended,
        text: shellProvider.shellActive == false
            ? Localization.appLocalizations().startLiveServer
            : Localization.appLocalizations().stopLiveServer,
        icon: shellProvider.shellActive == false
            ? Icons.miscellaneous_services_rounded
            : Icons.stop_circle_outlined,
        onTap: shellProvider.shellActive == false
            ? () => startLiveServer(context: context)
            : () => stopSSGServer(
                context: context,
                ssg: SSG.getSSGName(SSG.getSSGType(Preferences.getSSG()))),
      );
    });
  }

  @override
  Widget build(BuildContext context) => button(context);
}
