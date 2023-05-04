import 'dart:io';

import 'package:buhocms/src/provider/app/ssg_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';
import '../../../ssg/ssg.dart';
import '../../../utils/preferences.dart';
import '../../navigation_button.dart';
import '../../snackbar.dart';

class ParentFolderButton extends StatelessWidget {
  const ParentFolderButton({
    super.key,
    required this.setStateCallback,
    required this.isExtended,
  });

  final Function setStateCallback;
  final bool isExtended;

  String getSavePath() {
    var savePath = Preferences.getCurrentPath();
    if (savePath.endsWith(Platform.pathSeparator)) {
      savePath = savePath.substring(0, savePath.length - 1);
    }
    return savePath;
  }

  void onTap() {
    final contentFolder = SSG.getSSGContentFolder(
        ssg: SSG.getSSGType(Preferences.getSSG()), pathSeparator: false);
    final savePath = getSavePath();
    var savePathSplit = savePath.split(Platform.pathSeparator).last;

    final websitePathToCheck =
        '${Preferences.getSitePath()}${Platform.pathSeparator}$contentFolder';
    final newPath =
        savePath.substring(0, savePath.length - savePathSplit.length - 1);

    if (!newPath.contains(websitePathToCheck)) {
      showSnackbar(
        text: Localization.appLocalizations()
            .alreadyAtHighestLevel(contentFolder),
        seconds: 2,
      );
      return;
    }
    Preferences.setCurrentPath(
        savePath.substring(0, savePath.length - savePathSplit.length - 1));
    setStateCallback();
  }

  Widget button(BuildContext context) {
    return Consumer<SSGProvider>(builder: (_, __, ___) {
      final savePath = getSavePath();
      return NavigationButton(
        isExtended: isExtended,
        text:
            '${Platform.pathSeparator}${savePath.split(Platform.pathSeparator).last.replaceAll('', '\u{200B}')}',
        icon: Icons.drive_folder_upload_rounded,
        onTap: () => onTap(),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          overflow: TextOverflow
              .ellipsis, //https://github.com/flutter/flutter/issues/18761 "Text overflow with ellipsis is weird and ugly by design"
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => button(context);
}
