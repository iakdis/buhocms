import 'dart:io';

import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';

Future<void> runTerminalCommand({
  required BuildContext context,
  required String? workingDirectory,
  required String command,
  Function? successFunction,
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
        shell.kill();
        return;
      }
    } else {
      showSnackbar(text: e.toString(), seconds: 10);
      shell.kill();
      return;
    }
  }

  successFunction?.call();
  shell.kill();
}

void runTerminalCommandServer({
  required BuildContext context,
  required Shell shell,
  required Function successFunction,
  required Function errorFunction,
  required String command,
  required Function snackbarFunction,
}) async {
  snackbarFunction();
  successFunction();

  try {
    await shell.run(command).then((value) {
      return;
    });
  } catch (e) {
    if (e.toString() != 'ShellException(Killed by framework)') {
      showSnackbar(text: e.toString(), seconds: 10);
      errorFunction();
    }
  }

  /*try {
    await shell.run(command);
  } catch (e) {
    if (!Platform.isLinux) {
      catchFunction(e);
    } else {
      // If Linux error, check for Linux Flatpak sandbox issue
      try {
        // Check if platform is Flatpak
        await shell.run('flatpak-spawn --host ls');

        try {
          await shell.run('flatpak-spawn --host $command');
        } catch (_) {
          // Finally, if platform is Linux Flatpak but still error, command not working
          catchFunction(e);
        }
      } catch (_) {
        // Not Flatpak, show no error
        catchFunction(e);
      }
    }
  }*/
}
