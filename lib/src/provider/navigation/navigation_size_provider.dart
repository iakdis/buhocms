import 'package:flutter/material.dart';

class NavigationSizeProvider extends ChangeNotifier {
  double _navigationWidth = 64;
  double _fileNavigationWidth = 64;

  double get navigationWidth {
    return _navigationWidth;
  }

  double get fileNavigationWidth {
    return _fileNavigationWidth;
  }

  void setNavigationWidth(double width, {bool notify = true}) {
    _navigationWidth = width;
    if (notify) notifyListeners();
  }

  void setFileNavigationWidth(double width, {bool notify = true}) {
    _fileNavigationWidth = width;
    if (notify) notifyListeners();
  }
}
