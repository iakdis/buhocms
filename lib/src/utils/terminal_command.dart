import 'package:buhocms/src/provider/app/output_provider.dart';
import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';
import 'package:provider/provider.dart';

Future<void> runTerminalCommand({
  required BuildContext context,
  required String? workingDirectory,
  required String command,
  Function? successFunction,
}) async {
  final controller = ShellLinesController();
  final shell = Shell(
    workingDirectory: workingDirectory,
    stdout: controller.sink,
    stderr: controller.sink,
  );
  final outputProvider = Provider.of<OutputProvider>(context, listen: false);

  if (outputProvider.output.isNotEmpty) {
    outputProvider.setOutput('${outputProvider.output}\n\n');
  }

  controller.stream.asBroadcastStream().listen((event) {
    outputProvider.setOutput('${outputProvider.output}\n$event');
  });

  try {
    await shell.run(command);
  } catch (e) {
    showSnackbar(text: e.toString(), seconds: 10);
    shell.kill();
    return;
  }

  successFunction?.call();
  shell.kill();
}

void runTerminalCommandServer({
  required BuildContext context,
  required ShellLinesController controller,
  required Shell shell,
  required Function successFunction,
  required Function errorFunction,
  required String command,
  required Function snackbarFunction,
}) async {
  snackbarFunction();
  successFunction();

  final outputProvider = Provider.of<OutputProvider>(context, listen: false);

  if (outputProvider.output.isNotEmpty) {
    outputProvider.setOutput('${outputProvider.output}\n\n');
  }

  controller.stream.asBroadcastStream().listen((event) {
    outputProvider.setOutput('${outputProvider.output}\n$event');
  });

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
}
