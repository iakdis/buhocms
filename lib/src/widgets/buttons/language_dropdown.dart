import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../i18n/l10n.dart';
import '../../provider/app/locale_provider.dart';
import '../../utils/preferences.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(builder: (context, localeProvider, _) {
      return DropdownButton<String>(
        icon: const Icon(Icons.language),
        value: Preferences.getLanguage().isNotEmpty
            ? Preferences.getLanguage()
            : null,
        items: Localization.supportedLocales.map(
          (locale) {
            final name = Localization.getName(locale);

            return DropdownMenuItem(
              value: locale.toLanguageTag(),
              onTap: () => localeProvider.setLocale(locale),
              child: Text(name),
            );
          },
        ).toList()
          ..insert(
            0,
            DropdownMenuItem<String>(
              value: null,
              onTap: () => localeProvider.clearLocale(),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(Localization.appLocalizations().systemLanguage),
              ),
            ),
          ),
        onChanged: (_) {},
      );
    });
  }
}
