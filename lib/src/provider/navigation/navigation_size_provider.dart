import 'package:flutter/material.dart';

class NavigationSizeProvider extends ChangeNotifier {
  double _navigationWidth = 64;
  double _fileNavigationWidth = 64;
  bool _isExtendedNav = false;
  bool _isExtendedFileNav = false;

  double get navigationWidth {
    return _navigationWidth;
  }

  double get fileNavigationWidth {
    return _fileNavigationWidth;
  }

  bool get isExtendedNav => _isExtendedNav;
  bool get isExtendedFileNav => _isExtendedFileNav;

  void setNavigationWidth(double width, {bool notify = true}) {
    _navigationWidth = width;
    if (notify) notifyListeners();
  }

  void setFileNavigationWidth(double width, {bool notify = true}) {
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
