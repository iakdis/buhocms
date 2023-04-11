import 'dart:io';

import 'package:buhocms/src/utils/is_flatpak.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';

import '../i18n/l10n.dart';
import '../ssg/ssg.dart';
import '../widgets/snackbar.dart';

Future<String?> checkProgramInstalled({
  required BuildContext context,
  required String executable,
  required SSGTypes ssg,
  Function? notFound,
  Function(String)? found,
  bool showErrorSnackbar = true,
}) async {
  var finalExecutable = '';
  final errorText = Localization.appLocalizations().error_executableNotFound(
      '${executable[0].toUpperCase()}${executable.substring(1)}',
      '"$executable"');

  if (Platform.isWindows) {
    await which(executable).then((value) {
      finalExecutable = value ?? '';
    }).catchError((object) async {});
  } else {
    switch (ssg) {
      case SSGTypes.hugo:
      case SSGTypes.jekyll:
        final flatpak = await isFlatpak();
        if (flatpak) {
          final flags = <String>[];
          flags.insert(0, executable);
          flags.insert(0, 'which');
          if (ssg == SSGTypes.jekyll) {
            final home = Platform.environment['HOME'];
            final path = Platform.environment['PATH'];
            flags.insert(
                0, '--env=DEBIAN_DISABLE_RUBYGEMS_INTEGRATION=1'); // Jekyll
            flags.insert(0, '--env=PATH=$home/gems/bin:$path'); // Jekyll
            flags.insert(0, '--env=GEM_HOME=$home/gems'); // Jekyll
          }
          flags.insert(0, '--host');
          executable = 'flatpak-spawn';

          final result = await Process.run(executable, flags, runInShell: true);
          if (result.errText.contains('Portal call failed')) {
            await showFlatpakDialog();
          }
          finalExecutable = (result.stdout as String).trim();
        } else {
          await which(executable).then((value) {
            finalExecutable = value ?? '';
          }).catchError((object) async {});
        }
        break;
    }
  }

  if (finalExecutable.isEmpty) {
    notFound?.call();
    if (showErrorSnackbar) {
      showSnackbar(
        text: errorText,
        seconds: 5,
      );
    }
    return null;
  } else {
    found?.call(finalExecutable);
    return finalExecutable;
  }
}
