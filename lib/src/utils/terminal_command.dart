import 'dart:io';

import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';

Future<void> runTerminalCommand({
  required BuildContext context,
  required String? workingDirectory,
  required String command,
}) async {
  final shell = Shell(workingDirectory: workingDirectory);

  // Try to run command
  try {
    await shell.run(command);
  } catch (e) {
    // If error, check for Linux Flatpak sandbox issue
    if (Platform.isLinux) {
      try {
        await shell.run('flatpak-spawn --host $command');
      } catch (_) {
        // Finally, if platform is Flatpak but still error, command not working
        showSnackbar(text: e.toString(), seconds: 10);
      }
    } else {
      showSnackbar(text: e.toString(), seconds: 10);
    }
  }

  shell.kill();
}

void runTerminalCommandWithShell({
  required BuildContext context,
  required Shell shell,
  required Function successFunction,
  required String command,
}) async {
  // Try to run command
  shell.run(command).then((value) {
    // Command found, run it
  }).catchError((object) async {
    // If error, check for Linux Flatpak sandbox issue
    if (Platform.isLinux) {
      await shell.run('flatpak-spawn --host $command').then((value) {
        // If platform is Flatpak and no error, command working
      }).catchError((object) {
        // Finally, if platform is Flatpak but still error, command not working
        return;
      });
    }
    return;
  });
  successFunction();
}
