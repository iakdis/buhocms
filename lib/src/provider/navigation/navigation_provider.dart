import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int? _navigationIndex;

  int? get navigationIndex {
    _navigationIndex = Preferences.getPageIndex();
    return _navigationIndex;
  }

  void setNavigationIndex(int index) {
    Preferences.setPageIndex(index);
    _navigationIndex = index;
    notifyListeners();
  }

  void notifyAllListeners() {
    notifyListeners();
  }
}
