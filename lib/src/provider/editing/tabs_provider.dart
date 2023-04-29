import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';

import '../../logic/files.dart';
import '../navigation/navigation_provider.dart';

const tabWidth = 180.0;

class TabsProvider extends ChangeNotifier {
  List<MapEntry<String, int>> _tabs = [];
  final ScrollController _scrollController = ScrollController();
  List<GlobalKey> _globalKeys = [];

  ScrollController get scrollController {
    return _scrollController;
  }

  List<GlobalKey> get globalKeys {
    return _globalKeys;
  }

  void setGlobalKeys(List<GlobalKey> newGlobalKeys) {
    _globalKeys = newGlobalKeys;
  }

  List<MapEntry<String, int>> get tabs {
    _tabs = Preferences.getTabs();
    return _tabs;
  }

  Future<void> setTabs(
    List<MapEntry<String, int>> tabs, {
    bool updateFiles = false,
  }) async {
    if (updateFiles) {
      var allFiles = await getAllFiles();
      var updatedTabs = <MapEntry<String, int>>[];
      for (var i = 0; i < tabs.length; i++) {
        for (var j = 0; j < allFiles.length; j++) {
          if (allFiles[j].path == tabs[i].key) {
            updatedTabs.add(MapEntry(tabs[i].key, j));
            break;
          }
        }
      }
      _tabs = updatedTabs;
    } else {
      _tabs = tabs;
    }

    Preferences.setTabs(_tabs);
    notifyListeners();
  }

  void removeTab(int index,
      {NavigationPage page = NavigationPage.editing}) async {
    var tabs = _tabs;
    tabs.removeAt(index);

    await setTabs(tabs, updateFiles: true);

    if (page == NavigationPage.editing) scrollToTabIndex(tabIndex: index - 1);

    notifyListeners();
  }

  void scrollToTab({required int fileNavigationIndex}) {
    var tabIndex = 0;
    for (var i = 0; i < tabs.length; i++) {
      if (tabs[i].value == fileNavigationIndex) tabIndex = i;
    }

    scrollToTabIndex(tabIndex: tabIndex);
  }

  void scrollToTabIndex({required int tabIndex}) {
    scrollController.animateTo(
      tabWidth * tabIndex - tabWidth,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }
}
