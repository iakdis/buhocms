import 'dart:io';
import 'dart:math';

import 'package:buhocms/src/provider/app/output_provider.dart';
import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';
import 'package:provider/provider.dart';

import 'is_flatpak.dart';

Future<void> runTerminalCommand({
  required BuildContext context,
  required String? workingDirectory,
  required String executable,
  required List<String> flags,
  Function? successFunction,
}) async {
  final outputProvider = context.read<OutputProvider>();

  if (outputProvider.output.isNotEmpty) {
    outputProvider.setOutput('${outputProvider.output}\n\n');
  }

  final home = Platform.environment['HOME'];
  final path = Platform.environment['PATH'];

  final flatpak = await isFlatpak();
  if (flatpak) {
    flags.insert(0, executable);
    flags.insert(0, '--env=DEBIAN_DISABLE_RUBYGEMS_INTEGRATION=1'); // Jekyll
    flags.insert(0, '--env=PATH=$home/gems/bin:$path'); // Jekyll
    flags.insert(0, '--env=GEM_HOME=$home/gems'); // Jekyll
    flags.insert(0, '--host');
    executable = 'flatpak-spawn';
  }

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

  final pid = result.pid;

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
  required Shell shell,
  required ShellLinesController controller,
  required Function successFunction,
  required Function errorFunction,
  required String executable,
  required List<String> flags,
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
    final flatpak = await isFlatpak();
    if (flatpak) {
      final home = Platform.environment['HOME'];
      final path = Platform.environment['PATH'];
      flags.insert(0, executable);
      flags.insert(0, '--env=DEBIAN_DISABLE_RUBYGEMS_INTEGRATION=1'); // Jekyll
      flags.insert(0, '--env=PATH=$home/gems/bin:$path'); // Jekyll
      flags.insert(0, '--env=GEM_HOME=$home/gems'); // Jekyll
      flags.insert(0, '--host');
      executable = 'flatpak-spawn';
    }

    await shell.run('$executable ${flags.join(' ')}');
  } catch (e) {
    if (e.toString() != 'ShellException(Killed by framework)') {
      showSnackbar(text: e.toString(), seconds: 10);
      errorFunction();
    }
  }
}
