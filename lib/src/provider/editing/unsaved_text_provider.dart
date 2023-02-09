import 'package:flutter/material.dart';

import '../../ssg/hugo.dart';

class UnsavedTextProvider extends ChangeNotifier {
  bool _unsaved = false;
  String _unsavedText = 'UnsavedText';
  String _savedText = 'SavedText';

  String get unsavedText {
    return _unsavedText;
  }

  void setUnsavedText(String text) {
    _unsavedText = text;
    notifyListeners();
  }

  String get savedText {
    return _savedText;
  }

  void setSavedText(String text) {
    _savedText = text;
    //notifyListeners();
  }

  void setUnsaved(bool unsaved) {
    _unsaved = unsaved;
    notifyListeners();
  }

  bool unsaved({required List<GlobalKey<HugoWidgetState>> globalKey}) {
    _unsaved = false;
    for (var i = 0; i < globalKey.length; i++) {
      var saved = globalKey[i].currentState?.checkUnsaved(
          globalKey[i].currentState?.frontmatter.value ?? HugoType.typeString);
      if (saved == true) _unsaved = true;
    }
    if (savedText != unsavedText) _unsaved = true;

    /*final fileNavigationProvider = Provider.of<FileNavigationProvider>(context, listen: false);
    if (fileNavigationProvider.fileNavigationIndex == -1) {
      unsaved = false;
    }*/

    return _unsaved;
  }
}
