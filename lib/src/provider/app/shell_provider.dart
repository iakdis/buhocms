import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';

class ShellProvider extends ChangeNotifier {
  bool _shellActive = false;
  String test = '';
  Shell _shell = Shell(workingDirectory: Preferences.getSitePath());
  Shell _shellBuild = Shell(workingDirectory: Preferences.getSitePath());

  bool? get shellActive {
    return _shellActive;
  }

  void run(String script) {
    _shell.kill();
    _shell = Shell(workingDirectory: Preferences.getSitePath());
    if (_shellActive == false) _shell.run(script);
    _shellActive = true;
    notifyListeners();
  }

  void kill() {
    if (_shellActive == true) _shell.kill();
    _shellActive = false;
    notifyListeners();
  }

  Future<void> runBuild(String script) async {
    _shellBuild.kill();
    _shellBuild = Shell(workingDirectory: Preferences.getSitePath());
    await _shellBuild.run(script);
  }

  void killBuild() {
    _shellBuild.kill();
  }
}
