import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';

import '../../pages/editing_page.dart';

class EditingProvider extends ChangeNotifier {
  final GlobalKey<EditingPageState> _editingPageKey =
      GlobalKey<EditingPageState>();
  GlobalKey<EditingPageState> get editingPageKey => _editingPageKey;

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

  bool _isFrontmatterGUIMode = true;

  bool get isFrontmatterGUIMode {
    _isFrontmatterGUIMode = Preferences.getIsFrontmatterGUIMode();
    return _isFrontmatterGUIMode;
  }

  void setFrontmatterGUIMode(bool isFrontmatterGUIMode) {
    Preferences.setIsFrontmatterGUIMode(isFrontmatterGUIMode);
    _isFrontmatterGUIMode = isFrontmatterGUIMode;
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
