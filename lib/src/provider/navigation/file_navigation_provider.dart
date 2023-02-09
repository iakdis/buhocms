import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';

import '../../logic/files.dart';

class FileNavigationProvider extends ChangeNotifier {
  int _fileNavigationIndex = -1;

  final TextEditingController _controller = TextEditingController();
  String _initialText = '';
  String _markdownTextContent = '';
  String _frontMatterText = '';

  int get fileNavigationIndex {
    _fileNavigationIndex = Preferences.getFileIndex();
    return _fileNavigationIndex;
  }

  void setFileNavigationIndex(int index) {
    Preferences.setFileIndex(index);
    _fileNavigationIndex = index;
    notifyListeners();
  }

  String get initialText {
    return _initialText;
  }

  String get markdownTextContent {
    return _markdownTextContent;
  }

  String get frontMatterText {
    return _frontMatterText;
  }

  void setMarkdownTextContent(String text) {
    _markdownTextContent = text.trim();
    //notifyListeners();
  }

  void setFrontMatterText(String text) {
    _frontMatterText = text;
    //notifyListeners();
  }

  Future<void> setInitialTexts({bool dontExecute = false}) async {
    var allFiles = await getAllFiles();
    if (fileNavigationIndex > allFiles.length) {
      setFileNavigationIndex(-1);
    }

    //_initialText = allFiles[fileNavigationIndex ?? 0].readAsStringSync();
    if ((fileNavigationIndex) != -1) {
      _initialText = await allFiles[fileNavigationIndex].readAsString();
    }

    if (dontExecute == true) {
      return;
    } else {
      if (_initialText.isNotEmpty && _initialText.contains('---', 1)) {
        _markdownTextContent =
            _initialText.substring(_initialText.indexOf('---', 1) + 3).trim();
      }

      if (_initialText.isEmpty) {
        _frontMatterText = '---\n---';
      }
      if (_initialText.isNotEmpty && _initialText.contains('---', 1)) {
        _frontMatterText =
            initialText.substring(0, initialText.indexOf('---', 1) + 3).trim();
      }
      //BEFORE _controller.text = _initialText;
    }
  }

  TextEditingController get controller {
    //setInitialTexts();
    return _controller;
  }

  void addListenerController(Function() function) {
    _controller.addListener(function);
  }
}
