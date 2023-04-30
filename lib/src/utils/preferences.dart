import 'dart:convert';

import 'package:buhocms/src/ssg/ssg.dart';
import 'package:buhocms/src/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/navigation/navigation_provider.dart';
import '../ssg/frontmatter.dart';
import '../widgets/file_navigation/buttons/sort_button.dart';

class Preferences {
  static Map<String, dynamic> defaultPreferences() {
    return Map.fromEntries([
      const MapEntry(prefLanguage, ''),
      MapEntry(prefThemeMode, ThemeMode.system.name),
      const MapEntry(prefColorScheme, 27),
      MapEntry(prefPageIndex, NavigationPage.editing.index),
      const MapEntry(prefCurrentFileIndex, -1),
      const MapEntry(prefNavigationSize, 64.0),
      const MapEntry(prefFileNavigationSize, 64.0),
      const MapEntry(prefOnboardingCompleted, false),
      MapEntry(prefSSG, SSGTypes.hugo.name),
      const MapEntry(prefSitePath, null),
      const MapEntry(prefRecentSitePaths, {}),
      const MapEntry(prefCurrentPath, ''),
      const MapEntry(prefCurrentFile, null),
      const MapEntry(prefIsGUIMode, true),
      const MapEntry(prefIsFrontmatterGUIMode, true),
      MapEntry(prefSortMode, SortMode.name.name),
      MapEntry(
          prefFrontMatterAddList, json.encode(defaultFrontMatterAddList())),
      const MapEntry(prefDraggableMode, false),
      const MapEntry(prefTabs, null),
    ]);
  }

  static Future<void> clearPreferences() async => await _preferences!.clear();

  static Future<void> clearPreferencesSite() async {
    final defaultPrefs = defaultPreferences();
    final prefs = getPreferences();
    final deleteKeys = [
      prefCurrentFileIndex,
      prefCurrentPath,
      prefCurrentFile,
      prefTabs
    ];

    for (var i = 0; i < prefs.keys.length; i++) {
      final key = prefs.keys.toList()[i];
      for (var j = 0; j < deleteKeys.length; j++) {
        if (key == deleteKeys[j]) {
          prefs[key] = defaultPrefs[key];
        }
      }
    }

    String fromJson = json.encode(prefs);
    await _preferences!.setString(prefPreferences, fromJson);
  }

  static String getAllPreferences() {
    //https://gist.github.com/kasperpeulen/d61029fc0bc6cd104602
    var object = json.decode(_preferences!.getString(prefPreferences) ?? '');
    return const JsonEncoder.withIndent('  ').convert(object);
  }

  static Future<void> setAllPreferences(String preferences) async {
    await _preferences!.setString(prefPreferences, preferences);
  }

  static Future<void> setPreferences(String key, dynamic value) async {
    final preferences = getPreferences();
    preferences[key] = value;

    String fromJson = json.encode(preferences);
    await _preferences!.setString(prefPreferences, fromJson);
  }

  static Map<String, dynamic> getPreferences() {
    final defaultPrefs = defaultPreferences();

    final Map prefs = json.decode(
        _preferences!.getString(prefPreferences) ?? json.encode(defaultPrefs));

    final Map<String, dynamic> allPrefs = {};
    allPrefs.addEntries(prefs.entries.map((e) => MapEntry(e.key, e.value)));

    return allPrefs;
  }

  static dynamic getPreferencesEntry(String pref) {
    final defaultPrefs = defaultPreferences();
    final prefs = getPreferences();
    if (prefs.containsKey(pref)) {
      return prefs[pref];
    } else {
      return defaultPrefs[pref];
    }
  }

  static SharedPreferences? _preferences;

  static Future<void> init() async =>
      _preferences = await SharedPreferences.getInstance();

  //Language
  static Future<void> setLanguage(String locale) async =>
      await setPreferences(prefLanguage, locale);
  static String getLanguage() => getPreferencesEntry(prefLanguage);

  //Theme Mode
  static Future<void> setThemeMode(String theme) async =>
      await setPreferences(prefThemeMode, theme);
  static String getThemeMode() => getPreferencesEntry(prefThemeMode);

  //Color Scheme Index
  static Future<void> setColorSchemeIndex(int index) async =>
      await setPreferences(prefColorScheme, index);
  static int getColorSchemeIndex() => getPreferencesEntry(prefColorScheme);

  //Page Index
  static Future<void> setPageIndex(NavigationPage page) async =>
      await setPreferences(prefPageIndex, page.index);
  static NavigationPage getPageIndex() =>
      NavigationPage.values.elementAt(getPreferencesEntry(prefPageIndex));

  //File Index
  static Future<void> setFileIndex(int index) async =>
      await setPreferences(prefCurrentFileIndex, index);
  static int getFileIndex() => getPreferencesEntry(prefCurrentFileIndex);

  //Navigation Panel Size
  static Future<void> setNavigationSize(double index) async =>
      await setPreferences(prefNavigationSize, index);
  static double getNavigationSize() => getPreferencesEntry(prefNavigationSize);

  //File Navigation Panel Size
  static Future<void> setFileNavigationSize(double index) async =>
      await setPreferences(prefFileNavigationSize, index);
  static double getFileNavigationSize() =>
      getPreferencesEntry(prefFileNavigationSize);

  //Onboarding
  static Future<void> setOnBoardingComplete(bool complete) async =>
      await setPreferences(prefOnboardingCompleted, complete);
  static bool getOnBoardingComplete() =>
      getPreferencesEntry(prefOnboardingCompleted);

  //Site Path
  static Future<void> setSitePath(String path) async =>
      await setPreferences(prefSitePath, path);
  static String? getSitePath() => getPreferencesEntry(prefSitePath);

  //SSG
  static Future<void> setSSG(String ssg) async =>
      await setPreferences(prefSSG, ssg);
  static String getSSG() => getPreferencesEntry(prefSSG);

  //Recently opened site paths
  static Future<void> setRecentSitePaths(Map<String, SSGTypes> paths) async {
    Map<String, String> addListWithTypesStrings = {};
    addListWithTypesStrings
        .addEntries(paths.entries.map((e) => MapEntry(e.key, e.value.name)));

    String mapToStr = json.encode(addListWithTypesStrings);
    await setPreferences(prefRecentSitePaths, mapToStr);
  }

  static Map<String, SSGTypes> getRecentSitePaths() {
    final recentPaths =
        json.decode('${getPreferencesEntry(prefRecentSitePaths)}');
    Map strToMap = recentPaths is Map ? recentPaths : {};

    Map<String, SSGTypes> fromStringsToType = {};
    fromStringsToType.addEntries(strToMap.entries
        .map((e) => MapEntry(e.key, SSGTypes.values.byName(e.value))));

    return fromStringsToType;
  }

  //Save Path
  static Future<void> setCurrentPath(String path) async =>
      await setPreferences(prefCurrentPath, path);
  static String getCurrentPath() => getPreferencesEntry(prefCurrentPath);

  //Current File
  static Future<void> setCurrentFile(String path) async =>
      await setPreferences(prefCurrentFile, path);
  static String? getCurrentFile() => getPreferencesEntry(prefCurrentFile);

  //GUI Mode
  static Future<void> setIsGUIMode(bool isGUIMode) async =>
      await setPreferences(prefIsGUIMode, isGUIMode);
  static bool getIsGUIMode() => getPreferencesEntry(prefIsGUIMode);

  //Front matter GUI Mode
  static Future<void> setIsFrontmatterGUIMode(
          bool isFrontmatterGUIMode) async =>
      await setPreferences(prefIsFrontmatterGUIMode, isFrontmatterGUIMode);
  static bool getIsFrontmatterGUIMode() =>
      getPreferencesEntry(prefIsFrontmatterGUIMode);

  //Sort Mode
  static Future<void> setSortMode(SortMode sortMode) async =>
      await setPreferences(prefSortMode, sortMode.name);
  static String getSortMode() => getPreferencesEntry(prefSortMode);

  //Front Matter Add list
  static Future<void> setFrontMatterAddList(
      Map<String, FrontmatterType> frontMatterAddList) async {
    Map<String, String> addListWithTypesStrings = {};
    addListWithTypesStrings.addEntries(
        frontMatterAddList.entries.map((e) => MapEntry(e.key, e.value.name)));

    String mapToStr = json.encode(addListWithTypesStrings);
    await setPreferences(prefFrontMatterAddList, mapToStr);
  }

  static Map<String, String> defaultFrontMatterAddList() {
    Map<String, String> defaultStringsAndTypes = {
      'title': FrontmatterType.typeString.name,
      'date': FrontmatterType.typeDate.name,
      'draft': FrontmatterType.typeBool.name,
      'tags': FrontmatterType.typeList.name,
    };
    return defaultStringsAndTypes;
  }

  static Map<String, FrontmatterType> getFrontMatterAddList() {
    Map<String, String> defaultStringsAndTypesStrings = {};
    defaultStringsAndTypesStrings.addEntries(defaultFrontMatterAddList()
        .entries
        .map((e) => MapEntry(e.key, e.value)));

    Map strToMap = json.decode(getPreferencesEntry(prefFrontMatterAddList) ??
        json.encode(defaultStringsAndTypesStrings));

    Map<String, FrontmatterType> fromStringsToType = {};
    fromStringsToType.addEntries(strToMap.entries
        .map((e) => MapEntry(e.key, FrontmatterType.values.byName(e.value))));

    return fromStringsToType;
  }

  //SSG Content folder list
  static Future<void> setSSGContentList(
      Map<SSGTypes, String> frontMatterAddList) async {
    Map<String, String> addListWithTypesStrings = {};
    addListWithTypesStrings.addEntries(
        frontMatterAddList.entries.map((e) => MapEntry(e.key.name, e.value)));

    String mapToStr = json.encode(addListWithTypesStrings);
    await setPreferences(prefSSGContentList, mapToStr);
  }

  static Map<SSGTypes, String> getSSGContentList() {
    Map<String, String> defaultStringsAndTypesStrings = {
      ...SSG.defaultSSGContentList()
    };

    Map strToMap = json.decode(getPreferencesEntry(prefSSGContentList) ??
        json.encode(defaultStringsAndTypesStrings));

    Map<SSGTypes, String> fromStringsToType = {};
    fromStringsToType.addEntries(strToMap.entries
        .map((e) => MapEntry(SSGTypes.values.byName(e.key), e.value)));

    return fromStringsToType;
  }

  //Tabs
  static Future<void> setTabs(List<MapEntry<String, int>> tabs) async {
    Map<String, int> tabsMap = {};
    tabsMap.addEntries(tabs.map((e) => e));

    String mapToStr = json.encode(tabsMap);
    await setPreferences(prefTabs, mapToStr);
  }

  static List<MapEntry<String, int>> getTabs() {
    Map<String, int> tabsMap = {};

    Map strToMap =
        json.decode(getPreferencesEntry(prefTabs) ?? json.encode(tabsMap));

    Map<String, int> fromStringsToType = {};
    fromStringsToType
        .addEntries(strToMap.entries.map((e) => MapEntry(e.key, e.value)));

    return fromStringsToType.entries.map((e) => e).toList();
  }
}
