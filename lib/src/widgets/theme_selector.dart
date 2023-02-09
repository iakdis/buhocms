import 'dart:ui';

import 'package:buhocms/src/provider/app/theme_provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/preferences.dart';

// The width size of the scrolling button.
const double _kWidthOfScrollItem = 40;

class ThemeSelector extends StatefulWidget {
  const ThemeSelector({
    super.key,
  });

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  late ScrollController scrollController;
  late int schemeIndex;

  @override
  void initState() {
    super.initState();
    schemeIndex = Preferences.getColorSchemeIndex();

    scrollController = ScrollController(
      initialScrollOffset: _kWidthOfScrollItem * schemeIndex,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLight =
        Preferences.getThemeMode() == ThemeMode.dark.name ? false : true;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      child: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis
              .horizontal, //also see https://github.com/flutter/flutter/issues/75180
          child: Row(
            children: [
              for (var index = 0; index < FlexColor.schemesList.length; index++)
                FlexThemeModeOptionButton(
                  optionButtonBorderRadius: 12,
                  height: Preferences.getColorSchemeIndex() == index ? 26 : 20,
                  width: Preferences.getColorSchemeIndex() == index ? 26 : 20,
                  padding: const EdgeInsets.all(0.4),
                  optionButtonMargin: EdgeInsets.zero,
                  borderRadius: 0,
                  unselectedBorder: BorderSide.none,
                  selectedBorder: BorderSide(
                    color: Theme.of(context).primaryColorLight,
                    width: 5,
                  ),
                  onSelect: () {
                    setState(() {
                      schemeIndex = index;
                    });
                    var themeProvider =
                        Provider.of<ThemeProvider>(context, listen: false);
                    themeProvider.setColorScheme(index);
                  },
                  selected: Preferences.getColorSchemeIndex() == index,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  flexSchemeColor: FlexColor.schemesList[index].light,
                )
            ],
          ),
        ),
      ),
    );
  }
}
