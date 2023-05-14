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

  MenuThemeData menuTheme = const MenuThemeData(
    style: MenuStyle(
      padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 16.0)),
    ),
  );

  AppBarTheme appBarTheme(FlexScheme scheme) => AppBarTheme(
        color: FlexThemeData.light(scheme: scheme).primaryColor,
        foregroundColor:
            FlexThemeData.light(scheme: scheme).colorScheme.onPrimary,
        toolbarHeight: 46,
        titleSpacing: 0,
        titleTextStyle: const TextStyle(fontSize: 20),
      );

  TextButtonThemeData textButtonTheme(FlexScheme scheme, {bool dark = false}) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dark
              ? FlexThemeData.dark(scheme: scheme).colorScheme.onBackground
              : FlexThemeData.light(scheme: scheme).colorScheme.primary,
        ),
      );

  ElevatedButtonThemeData elevatedButtonTheme(FlexScheme scheme) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FlexThemeData.light(scheme: scheme).primaryColor,
          foregroundColor:
              FlexThemeData.light(scheme: scheme).colorScheme.onPrimary,
        ),
      );

  ThemeData lightTheme() {
    final scheme = FlexScheme.values.elementAt(colorSchemeIndex ?? 0);
    return FlexThemeData.light(
      useMaterial3: true,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      scheme: scheme,
    ).copyWith(
      menuTheme: menuTheme,
      appBarTheme: appBarTheme(scheme),
      textButtonTheme: textButtonTheme(scheme),
      elevatedButtonTheme: elevatedButtonTheme(scheme),
    );
  }

  ThemeData darkTheme() {
    final scheme = FlexScheme.values.elementAt(colorSchemeIndex ?? 0);
    return FlexThemeData.dark(
      useMaterial3: true,
      primary: FlexThemeData.light(scheme: scheme).primaryColor,
      secondary: FlexThemeData.light(scheme: scheme).colorScheme.secondary,
      tertiary: FlexThemeData.light(scheme: scheme).colorScheme.tertiary,
      primaryContainer:
          FlexThemeData.light(scheme: scheme).colorScheme.primaryContainer,
      secondaryContainer:
          FlexThemeData.light(scheme: scheme).colorScheme.secondaryContainer,
      tertiaryContainer:
          FlexThemeData.light(scheme: scheme).colorScheme.tertiaryContainer,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      scheme: scheme,
      scaffoldBackground: const Color(0xFF262626),
    ).copyWith(
      menuTheme: menuTheme,
      appBarTheme: appBarTheme(scheme),
      textButtonTheme: textButtonTheme(scheme, dark: true),
      elevatedButtonTheme: elevatedButtonTheme(scheme),
    );
  }
}
