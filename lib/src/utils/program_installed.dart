import 'dart:io';

import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';

import '../i18n/l10n.dart';
import '../ssg/ssg.dart';
import '../widgets/snackbar.dart';

void checkProgramInstalled({
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
    //final shell = Shell(runInShell: true);
    // await shell.run('which $executable').then((value) {
    //   finalExecutable = value.outText;
    // }).catchError((object) async {});
    switch (ssg) {
      case SSGTypes.hugo:
        await which(executable).then((value) {
          finalExecutable = value ?? '';
        }).catchError((object) async {});
        break;
      case SSGTypes.jekyll:
        await which(executable).then((value) {
          finalExecutable = value ?? '';
        }).catchError((object) async {});
        break;
      default:
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
  } else {
    found?.call(finalExecutable);
  }
}
