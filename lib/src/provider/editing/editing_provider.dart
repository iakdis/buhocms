import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';

import '../../pages/editing_page.dart';
import '../../ssg/frontmatter.dart';

class EditingProvider extends ChangeNotifier {
  List<GlobalKey<FrontmatterWidgetState>> _frontmatterKeys = [];
  List<GlobalKey<FrontmatterWidgetState>> get frontmatterKeys =>
      _frontmatterKeys;

  void setFrontmatterKeys(List<GlobalKey<FrontmatterWidgetState>> newKeys) {
    _frontmatterKeys = newKeys;
    notifyListeners();
  }

  final GlobalKey<EditingPageState> _editingPageKey =
      GlobalKey<EditingPageState>();
  GlobalKey<EditingPageState> get editingPageKey => _editingPageKey;

  final GlobalKey<MarkdownToolbarState> _markdownToolbarKey =
      GlobalKey<MarkdownToolbarState>();
  GlobalKey<MarkdownToolbarState> get markdownToolbarKey => _markdownToolbarKey;

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
