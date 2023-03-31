import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';

import '../../logic/files.dart';

class FileNavigationProvider extends ChangeNotifier {
  int _fileNavigationIndex = -1;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerFrontmatter = TextEditingController();
  String _initialText = '';
  String _markdownTextContent = '';
  String _frontMatterText = '';

  double? _textFieldHeight;

  double? get textFieldHeight => _textFieldHeight;

  void setTextFieldHeight(double height) {
    _textFieldHeight = height;
    notifyListeners();
  }

  int get fileNavigationIndex {
    _fileNavigationIndex = Preferences.getFileIndex();
    return _fileNavigationIndex;
  }

  void setFileNavigationIndex(int index) {
    Preferences.setFileIndex(index);
    _fileNavigationIndex = index;
    _textFieldHeight = null;
    notifyListeners();
  }

  String get initialText => _initialText;

  String get markdownTextContent => _markdownTextContent;

  String get frontMatterText => _frontMatterText;

  void setMarkdownTextContent(String text) =>
      _markdownTextContent = text.trim();

  void setFrontMatterText(String text) => _frontMatterText = text;

  Future<void> setInitialTexts({bool dontExecute = false}) async {
    var allFiles = await getAllFiles();
    if (fileNavigationIndex > allFiles.length) {
      setFileNavigationIndex(-1);
    }

    //_initialText = allFiles[fileNavigationIndex ?? 0].readAsStringSync();
    if ((fileNavigationIndex) != -1) {
      _initialText = allFiles.isEmpty
          ? ''
          : await allFiles[fileNavigationIndex].readAsString();
    }

    if (dontExecute == true) {
      return;
    } else {
      if (_initialText.isNotEmpty && _initialText.contains('---', 1)) {
        _markdownTextContent =
            _initialText.substring(_initialText.indexOf('---', 1) + 3).trim();
      } else if (_initialText.isEmpty) {
        _markdownTextContent = '';
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

  TextEditingController get controllerFrontmatter {
    return _controllerFrontmatter;
  }

  void addListenerController(Function() function) {
    _controller.addListener(function);
  }
}
