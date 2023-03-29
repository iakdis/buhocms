import 'dart:io';
import 'dart:math';

import 'package:buhocms/src/provider/app/output_provider.dart';
import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';
import 'package:provider/provider.dart';

Future<void> runTerminalCommand({
  required BuildContext context,
  required String? workingDirectory,
  required String executable,
  required List<String> flags,
  Function? successFunction,
}) async {
  final outputProvider = context.read<OutputProvider>();
  int pid;

  if (outputProvider.output.isNotEmpty) {
    outputProvider.setOutput('${outputProvider.output}\n\n');
  }

  final home = Platform.environment['HOME'];
  final path = Platform.environment['PATH'];

  final result = await Process.run(
    executable,
    flags,
    runInShell: true,
    workingDirectory: workingDirectory,
    environment: {
      'GEM_HOME': '$home/gems', // Jekyll
      'PATH': '$home/gems/bin:$path', // Jekyll
      'DEBIAN_DISABLE_RUBYGEMS_INTEGRATION': '1', // Jekyll
    },
  );

  var output = '${outputProvider.output}\n\$ $executable';
  if (flags.isNotEmpty) output += ' ${flags.join(" ")}';
  outputProvider.setOutput(output);
  outputProvider.setOutput('${outputProvider.output}\n${result.stdout}');

  pid = result.pid;

  final exitCode = result.exitCode;
  final errText = (result.stderr as String).trim();

  if (exitCode != 0) {
    outputProvider.setOutput('${outputProvider.output}\n$errText');
    final errTextMax = errText.substring(0, min(errText.length, 150));
    final trailingEllipsis = errText.length > 150 ? '...' : '';
    showSnackbar(
      text: 'Exit code $exitCode:\n$errTextMax$trailingEllipsis',
      seconds: 10,
    );
    Process.killPid(pid);
    return;
  }

  successFunction?.call();
  Process.killPid(pid);
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
