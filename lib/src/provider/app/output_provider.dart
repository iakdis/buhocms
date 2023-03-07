import 'package:flutter/material.dart';

class OutputProvider extends ChangeNotifier {
  bool _showOutput = false;
  bool get showOutput => _showOutput;

  void setShowOutput(bool show) {
    _showOutput = show;
    notifyListeners();
  }

  String _output = '';
  String get output => _output;

  void setOutput(String output) {
    _output = output;
    notifyListeners();
  }

  void clearOutput() {
    _output = '';
    notifyListeners();
  }
}
