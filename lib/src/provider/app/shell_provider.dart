import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';

class ShellProvider extends ChangeNotifier {
  bool _shellActive = false;
  Shell _shell = Shell(workingDirectory: Preferences.getSitePath());

  Shell get shell => _shell;

  bool? get shellActive {
    return _shellActive;
  }

  void updateShell() {
    _shell.kill();
    _shell = Shell(workingDirectory: Preferences.getSitePath());
    notifyListeners();
  }

  void setShellActive(bool active) {
    _shellActive = active;
    notifyListeners();
  }

  void kill() {
    if (_shellActive == true) _shell.kill();
    _shellActive = false;
    notifyListeners();
  }
}
