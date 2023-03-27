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
  String? command,
  bool showErrorSnackbar = true,
}) async {
  var finalExecutable = '';
  final shell = Shell();
  final errorText = Localization.appLocalizations().error_executableNotFound(
      '${executable[0].toUpperCase()}${executable.substring(1)}', '"$command"');

  if (Platform.isWindows) {
    // Try to get executable
    await which(executable).then((value) {
      // Executable found, set it
      finalExecutable = value ?? '';
    }).catchError((object) async {
      // Not installed
    });
  } else {
    // Try to get executable
    await shell.run('which $executable').then((value) {
      // Executable found, set it
      finalExecutable = value.outText;
    }).catchError((object) async {
      // Not installed
    });
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
