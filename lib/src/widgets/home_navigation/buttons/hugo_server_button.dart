import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../logic/buho_functions.dart';

class HugoServerButton extends StatelessWidget {
  const HugoServerButton({
    super.key,
    required this.isExtended,
  });

  final bool isExtended;

  Widget _hugoServerButton({
    required String text,
    required IconData icon,
    required Function onTap,
  }) {
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
                  icon,
                  size: 32.0,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                isExtended
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 16.0,
                          ),
                          SizedBox(
                            width: constraints.maxWidth - 80,
                            child: Text(
                              text,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
          onTap: () => onTap(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShellProvider>(
      builder: (context, shellProvider, _) {
        return _hugoServerButton(
          text: shellProvider.shellActive == false
              ? AppLocalizations.of(context)!.startHugoServer
              : AppLocalizations.of(context)!.stopHugoServer,
          icon: shellProvider.shellActive == false
              ? Icons.miscellaneous_services_rounded
              : Icons.stop_circle_outlined,
          onTap: shellProvider.shellActive == false
              ? () => startHugoServer(context: context)
              : () => stopHugoServer(context: context),
        );
      },
    );
  }
}
