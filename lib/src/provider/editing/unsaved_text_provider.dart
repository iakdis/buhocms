import 'package:flutter/material.dart';

import '../../ssg/frontmatter.dart';

class UnsavedTextProvider extends ChangeNotifier {
  bool _unsaved = false;
  String _unsavedText = '';
  String _savedText = '';
  String _unsavedTextFrontmatter = '';
  String _savedTextFrontmatter = '';

  String get unsavedText => _unsavedText;

  void setUnsavedText(String text) {
    _unsavedText = text;
    notifyListeners();
  }

  String get savedText => _savedText;

  void setSavedText(String text) => _savedText = text;

  String get unsavedTextFrontmatter => _unsavedTextFrontmatter;

  void setUnsavedTextFrontmatter(String text) {
    _unsavedTextFrontmatter = text;
    notifyListeners();
  }

  String get savedTextFrontmatter => _savedTextFrontmatter;

  void setSavedTextFrontmatter(String text) => _savedTextFrontmatter = text;

  void setUnsaved(bool unsaved) {
    _unsaved = unsaved;
    notifyListeners();
  }

  bool unsaved({required List<GlobalKey<FrontmatterWidgetState>> globalKey}) {
    _unsaved = false;
    for (var i = 0; i < globalKey.length; i++) {
      var saved = globalKey[i].currentState?.checkUnsaved(
          globalKey[i].currentState?.frontmatter.value ?? HugoType.typeString);
      if (saved == true) _unsaved = true;
    }
    if (savedText != unsavedText ||
        savedTextFrontmatter != unsavedTextFrontmatter) _unsaved = true;

    /*final fileNavigationProvider = Provider.of<FileNavigationProvider>(context, listen: false);
    if (fileNavigationProvider.fileNavigationIndex == -1) {
      unsaved = false;
    }*/

    return _unsaved;
  }
}
