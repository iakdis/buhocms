import 'dart:io';

import 'package:buhocms/src/provider/app/ssg_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';
import '../../../ssg/ssg.dart';
import '../../../utils/preferences.dart';
import '../../snackbar.dart';

class ParentFolderButton extends StatelessWidget {
  const ParentFolderButton({
    super.key,
    required this.setStateCallback,
    required this.isExtended,
  });

  final Function setStateCallback;
  final bool isExtended;

  Widget parentFolderButton({required BuildContext context}) {
    context.watch<SSGProvider>();

    final contentFolder = SSG.getSSGContentFolder(
        ssg: SSGTypes.values.byName(Preferences.getSSG()),
        pathSeparator: false);
    var savePath = Preferences.getCurrentPath();
    if (savePath.endsWith(Platform.pathSeparator)) {
      savePath = savePath.substring(0, savePath.length - 1);
    }
    var savePathSplit = savePath.split(Platform.pathSeparator).last;

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
                  Icons.drive_folder_upload_rounded,
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
                          softWrap: false,
                          maxLines: 1,
                          '${Platform.pathSeparator}${savePath.split(Platform.pathSeparator).last.replaceAll('', '\u{200B}')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            overflow: TextOverflow
                                .ellipsis, //https://github.com/flutter/flutter/issues/18761 "Text overflow with ellipsis is weird and ugly by design"
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          onTap: () {
            if (savePathSplit.contains(contentFolder)) {
              showSnackbar(
                text: Localization.appLocalizations()
                    .alreadyAtHighestLevel(contentFolder),
                seconds: 2,
              );
              return;
            }
            Preferences.setCurrentPath(savePath.substring(
                0, savePath.length - savePathSplit.length - 1));
            setStateCallback();
          }, //this.index = index),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => parentFolderButton(context: context);
}
