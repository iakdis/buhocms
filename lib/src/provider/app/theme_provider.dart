import 'package:buhocms/src/utils/preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode? _themeMode;
  int? _colorSchemeIndex;

  ThemeMode? themeMode() {
    _themeMode = Preferences.getThemeMode().isNotEmpty
        ? Themes.getThemeModeFromName(Preferences.getThemeMode())
        : ThemeMode.system;
    return _themeMode;
  }

  void setTheme(ThemeMode theme) {
    Preferences.setThemeMode(theme.name);
    _themeMode = theme;
    notifyListeners();
  }

  void setColorScheme(int index) {
    _colorSchemeIndex = index;
    Preferences.setColorSchemeIndex(index);
    notifyListeners();
  }

  int? colorSchemeIndex() {
    _colorSchemeIndex = Preferences.getColorSchemeIndex();
    return _colorSchemeIndex;
  }
}

class Themes {
  Themes(this.colorSchemeIndex);

  int? colorSchemeIndex;

  ThemeData lightTheme() {
    return FlexThemeData.light(
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
    ).copyWith(
      appBarTheme: const AppBarTheme(
        toolbarHeight: 46,
        titleSpacing: 0,
      ),
    );
  }

  ThemeData darkTheme() {
    return FlexThemeData.dark(
      primary: FlexThemeData.light(
        scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
      ).primaryColorLight,
      secondary: FlexThemeData.light(
        scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
      ).colorScheme.secondary,
      tertiary: FlexThemeData.light(
        scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
      ).colorScheme.tertiary,
      primaryContainer: FlexThemeData.light(
        scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
      ).colorScheme.primaryContainer,
      secondaryContainer: FlexThemeData.light(
        scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
      ).colorScheme.secondaryContainer,
      tertiaryContainer: FlexThemeData.light(
        scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
      ).colorScheme.tertiaryContainer,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
      background: const Color(0xFF212121),
    ).copyWith(
      appBarTheme: const AppBarTheme(
        toolbarHeight: 46,
        titleSpacing: 0,
      ),
    );
  }

  static ThemeMode getThemeModeFromName(String themeModeName) {
    if (themeModeName == ThemeMode.system.name) {
      return ThemeMode.system;
    } else if (themeModeName == ThemeMode.light.name) {
      return ThemeMode.light;
    } else if (themeModeName == ThemeMode.dark.name) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }
}
