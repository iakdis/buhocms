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
    if (schemeIndex != 27 &&
        schemeIndex != 11 &&
        schemeIndex != 8 &&
        schemeIndex != 9 &&
        schemeIndex != 4 &&
        schemeIndex != 29 &&
        schemeIndex != 14 &&
        schemeIndex != 23 &&
        schemeIndex != 33 &&
        schemeIndex != 6) {
      const defaultTheme = 27;

      Preferences.setColorSchemeIndex(defaultTheme);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ThemeProvider>(context, listen: false)
            .setColorScheme(defaultTheme);
      });
    }

    scrollController = ScrollController(
      initialScrollOffset: _kWidthOfScrollItem * schemeIndex,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  List<FlexSchemeData> schemesList() {
    return [
      FlexColor.schemesList[27],
      FlexColor.schemesList[11],
      FlexColor.schemesList[8],
      FlexColor.schemesList[9],
      FlexColor.schemesList[4],
      FlexColor.schemesList[29],
      FlexColor.schemesList[14],
      FlexColor.schemesList[23],
      FlexColor.schemesList[33],
      FlexColor.schemesList[6],
    ];
  }

  List<Widget> colorWidgets() {
    final list = <Widget>[];

    for (var index = 0; index < schemesList().length; index++) {
      var realIndex = 0;
      for (var i = 0; i < FlexColor.schemesList.length; i++) {
        if (FlexColor.schemesList[i].name == schemesList()[index].name) {
          realIndex = i;
        }
      }

      list.add(
        Tooltip(
          message: schemesList()[index].name,
          child: FlexThemeModeOptionButton(
            optionButtonBorderRadius: 12,
            height: Preferences.getColorSchemeIndex() == realIndex ? 26 : 20,
            width: Preferences.getColorSchemeIndex() == realIndex ? 26 : 20,
            padding: const EdgeInsets.all(0.4),
            optionButtonMargin: EdgeInsets.zero,
            borderRadius: 0,
            unselectedBorder: BorderSide.none,
            selectedBorder: BorderSide(
                color: Theme.of(context).primaryColorLight, width: 5),
            onSelect: () {
              setState(() => schemeIndex = index);
              Provider.of<ThemeProvider>(context, listen: false)
                  .setColorScheme(realIndex);
            },
            selected: Preferences.getColorSchemeIndex() == realIndex,
            backgroundColor: Theme.of(context).colorScheme.surface,
            flexSchemeColor: schemesList()[index].light,
          ),
        ),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
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
          scrollDirection: Axis.horizontal,
          child: Row(children: colorWidgets()),
        ),
      ),
    );
  }
}
