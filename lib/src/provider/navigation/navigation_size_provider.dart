import 'package:flutter/material.dart';

class NavigationSizeProvider extends ChangeNotifier {
  int _navigationWidth = 64;
  int _fileNavigationWidth = 64;
  bool _isExtendedNav = false;
  bool _isExtendedFileNav = false;

  int get navigationWidth => _navigationWidth;
  int get fileNavigationWidth => _fileNavigationWidth;

  bool get isExtendedNav => _isExtendedNav;
  bool get isExtendedFileNav => _isExtendedFileNav;

  void setNavigationWidth(int width, {bool notify = true}) {
    _navigationWidth = width;
    if (notify) notifyListeners();
  }

  void setFileNavigationWidth(int width, {bool notify = true}) {
    _fileNavigationWidth = width;
    if (notify) notifyListeners();
  }

  void setIsExtendedNav(bool extended, {bool notify = true}) {
    _isExtendedNav = extended;
    if (notify) notifyListeners();
  }

  void setIsExtendedFileNav(bool extended, {bool notify = true}) {
    _isExtendedFileNav = extended;
    if (notify) notifyListeners();
  }
}
