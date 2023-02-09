import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../i18n/l10n.dart';
import '../../provider/app/locale_provider.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(builder: (context, value, _) {
      return DropdownButton(
        icon: const Icon(Icons.language),
        value: value.locale,
        items: Localization.supportedLocales.map(
          (locale) {
            final name = Localization.getName(locale.languageCode);

            return DropdownMenuItem(
              value: locale,
              onTap: () => Provider.of<LocaleProvider>(context, listen: false)
                  .setLocale(locale),
              child: Text(name),
            );
          },
        ).toList()
          ..insert(
            0,
            DropdownMenuItem<Locale>(
              value: null,
              onTap: () => Provider.of<LocaleProvider>(context, listen: false)
                  .clearLocale(),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(AppLocalizations.of(context)!.systemLanguage),
              ),
            ),
          ),
        onChanged: (_) {},
      );
    });
  }
}
