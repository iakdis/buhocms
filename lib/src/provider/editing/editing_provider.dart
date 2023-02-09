import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';

class EditingProvider extends ChangeNotifier {
  bool _isGUIMode = false;

  bool get isGUIMode {
    _isGUIMode = Preferences.getIsGUIMode();
    return _isGUIMode;
  }

  void setIsGUIMode(bool isGUIMode) {
    Preferences.setIsGUIMode(isGUIMode);
    _isGUIMode = isGUIMode;
    notifyListeners();
  }

  String _markdownViewerText = 'Markdown viewer text';

  String get markdownViewerText {
    return _markdownViewerText;
  }

  void setMarkdownViewerText(String text) {
    _markdownViewerText = text;
    notifyListeners();
  }
}
