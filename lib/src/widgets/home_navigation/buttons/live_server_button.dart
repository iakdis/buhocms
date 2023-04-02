import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/buho_functions.dart';
import '../../../ssg/ssg.dart';

class LiveServerButton extends StatelessWidget {
  const LiveServerButton({super.key, required this.isExtended});

  final bool isExtended;

  Widget liveServerButton() {
    return Consumer<ShellProvider>(builder: (context, shellProvider, _) {
      return LayoutBuilder(builder: (context, constraints) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: shellProvider.shellActive == false
                ? () => startLiveServer(context: context)
                : () => stopSSGServer(
                    context: context,
                    ssg: SSG.getSSGName(SSG.getSSGType(Preferences.getSSG()))),
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
                    shellProvider.shellActive == false
                        ? Icons.miscellaneous_services_rounded
                        : Icons.stop_circle_outlined,
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
                            shellProvider.shellActive == false
                                ? Localization.appLocalizations()
                                    .startLiveServer
                                : Localization.appLocalizations()
                                    .stopLiveServer,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) => liveServerButton();
}
