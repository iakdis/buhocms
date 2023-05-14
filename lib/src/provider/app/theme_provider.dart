import 'package:buhocms/src/utils/preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode? _themeMode;
  int? _colorSchemeIndex;

  ThemeMode? themeMode() {
    _themeMode = Preferences.getThemeMode().isNotEmpty
        ? ThemeMode.values.byName(Preferences.getThemeMode())
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

  AppBarTheme appBarTheme = const AppBarTheme(
    toolbarHeight: 46,
    titleSpacing: 0,
  );

  ThemeData lightTheme() {
    return FlexThemeData.light(
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
    ).copyWith(
      appBarTheme: appBarTheme,
    );
  }

  ThemeData darkTheme() {
    return FlexThemeData.dark(
      primary: FlexThemeData.light(
        scheme: FlexScheme.values.elementAt(colorSchemeIndex ?? 0),
      ).primaryColor,
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
      appBarTheme: appBarTheme,
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(Colors.white),
        ),
      ),
    );
  }
}
