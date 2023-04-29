import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';

enum NavigationPage {
  editing,
  settings,
}

class NavigationProvider extends ChangeNotifier {
  NavigationPage? _navigationPage;

  NavigationPage? get navigationPage {
    _navigationPage = Preferences.getPageIndex();
    return _navigationPage;
  }

  void setNavigationPage(NavigationPage page) {
    Preferences.setPageIndex(page);
    _navigationPage = page;
    notifyListeners();
  }

  void setEditingPage() {
    Preferences.setPageIndex(NavigationPage.editing);
    _navigationPage = NavigationPage.editing;
    notifyListeners();
  }

  void setSettingsPage() {
    Preferences.setPageIndex(NavigationPage.settings);
    _navigationPage = NavigationPage.settings;
    notifyListeners();
  }

  void notifyAllListeners() {
    notifyListeners();
  }
}
