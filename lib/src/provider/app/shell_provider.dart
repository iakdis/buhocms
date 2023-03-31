import 'dart:io';

import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';

class ShellProvider extends ChangeNotifier {
  ShellLinesController _controller = ShellLinesController();
  ShellLinesController get controller => _controller;

  void updateController() {
    _controller.close();
    _controller = ShellLinesController();
    notifyListeners();
  }

  bool _shellActive = false;
  int? _pid;

  Shell? _shell;

  Shell shell() {
    _shell?.kill();
    _shell = Shell(
      workingDirectory: Preferences.getSitePath(),
      stdout: _controller.sink,
      stderr: _controller.sink,
    );
    return _shell!;
  }

  bool? get shellActive => _shellActive;

  void updateShell() {
    _shell?.kill();
    _shell = Shell(
      workingDirectory: Preferences.getSitePath(),
      stdout: _controller.sink,
      stderr: _controller.sink,
    );
    notifyListeners();
  }

  void setShellActive(bool active, int pid) {
    _shellActive = active;
    _pid = pid;
    notifyListeners();
  }

  void kill() {
    if (_shellActive == true && _pid != null) Process.killPid(_pid!);
    _shellActive = false;
    notifyListeners();
  }
}
