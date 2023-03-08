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

  void setShellActive(bool active) {
    _shellActive = active;
    notifyListeners();
  }

  void kill() {
    if (_shellActive == true) _shell?.kill();
    _shellActive = false;
    notifyListeners();
  }
}
