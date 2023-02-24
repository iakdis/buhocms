import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OpenLocalhostButton extends StatelessWidget {
  const OpenLocalhostButton({
    super.key,
    required this.isExtended,
  });

  final bool isExtended;

  Future<void> _openLocalhost() async {
    var url = Uri.parse('http://localhost:1313');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget _openLocalhostButton() {
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
                  //index == this.index ? icon : iconUnselected,
                  Icons.open_in_new,
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
                              AppLocalizations.of(context)!.openHugoServer,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
          onTap: () async {
            await _openLocalhost();
          }, //this.index = index),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _openLocalhostButton();
  }
}
