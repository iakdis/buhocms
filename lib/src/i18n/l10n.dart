import 'package:flutter/material.dart';

class Localization {
  static final supportedLocales = [
    const Locale('en', ''), //English first, as a fallback

    const Locale('de', ''),
  ];

  static String getName(Locale locale) {
    switch (locale.languageCode) {
      case 'de':
        return 'Deutsch';
      case 'en':
      default:
        return 'English';
    }
  }
}
