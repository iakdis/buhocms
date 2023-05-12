import 'package:buhocms/src/provider/app/output_provider.dart';
import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:buhocms/src/utils/globals.dart';
import 'package:buhocms/src/utils/preferences.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/gui_mode_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/build_website_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/live_server_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/navigation_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/open_server_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/open_build_button.dart';
import 'package:buhocms/src/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/l10n.dart';
import '../../provider/navigation/navigation_provider.dart';
import '../../provider/navigation/navigation_size_provider.dart';
import '../../ssg/ssg.dart';
import '../resize_bar.dart';
import 'buttons/terminal_output_button.dart';

class HomeNavigationDrawer extends StatefulWidget {
  const HomeNavigationDrawer({super.key});

  @override
  State<HomeNavigationDrawer> createState() => _HomeNavigationDrawerState();
}

class _HomeNavigationDrawerState extends State<HomeNavigationDrawer> {
  int lastWidth = 64;

  int top = 0;
  int left = 0;

  @override
  void initState() {
    final navigationSizeProvider =
        Provider.of<NavigationSizeProvider>(context, listen: false);
    navigationSizeProvider.setNavigationWidth(
      Preferences.getNavigationSize(),
      notify: false,
    );
    lastWidth = Preferences.getNavigationSize();
    navigationSizeProvider.setIsExtendedNav(
      navigationSizeProvider.navigationWidth > 64 ? true : false,
      notify: false,
    );

    super.initState();
  }

  Widget divider() => Divider(color: Theme.of(context).colorScheme.onSecondary);

  List<Widget> navigationBarWidgets(
          {required NavigationSizeProvider navigationSizeProvider}) =>
      [
        Align(
          alignment: navigationSizeProvider.isExtendedNav
              ? Alignment.centerRight
              : Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              child: RotatedBox(
                quarterTurns: 3,
                child: Icon(
                  navigationSizeProvider.isExtendedNav
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 48.0,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              onTap: () => setState(() {
                if (navigationSizeProvider.isExtendedNav) {
                  navigationSizeProvider.setIsExtendedNav(false);
                  navigationSizeProvider.setNavigationWidth(64);
                } else {
                  navigationSizeProvider.setIsExtendedNav(true);
                  navigationSizeProvider
                      .setNavigationWidth(lastWidth > 200 ? lastWidth : 200);
                }
                Preferences.setNavigationSize(
                    navigationSizeProvider.navigationWidth);
              }),
            ),
          ),
        ),
        divider(),
        CustomTooltip(
          message: Localization.appLocalizations().editingPage,
          child: HomeNavigationButton(
            isExtended: navigationSizeProvider.isExtendedNav,
            icon: Icons.edit,
            iconUnselected: Icons.edit_outlined,
            buttonText: Localization.appLocalizations().editingPage,
            page: NavigationPage.editing,
          ),
        ),
        divider(),
        CustomTooltip(
          message: Localization.appLocalizations().guiMode,
          child: GUIModeButton(
              isExtended: navigationSizeProvider.isExtendedNav,
              isGUIMode: true),
        ),
        CustomTooltip(
          message: Localization.appLocalizations().textMode,
          child: GUIModeButton(
              isExtended: navigationSizeProvider.isExtendedNav,
              isGUIMode: false),
        ),
        divider(),
        CustomTooltip(
          message: Provider.of<ShellProvider>(context).shellActive == true
              ? Localization.appLocalizations().stopLiveServer
              : Localization.appLocalizations().startLiveServer,
          child: LiveServerButton(
              isExtended: navigationSizeProvider.isExtendedNav),
        ),
        CustomTooltip(
          message: SSG.getSSGLiveServer(
              ssg: SSGTypes.values.byName(Preferences.getSSG())),
          child: OpenServerButton(
              isExtended: navigationSizeProvider.isExtendedNav),
        ),
        divider(),
        CustomTooltip(
          message: Localization.appLocalizations().buildWebsite(
              SSG.getSSGName(SSGTypes.values.byName(Preferences.getSSG()))),
          child: BuildWebsiteButton(
              isExtended: navigationSizeProvider.isExtendedNav),
        ),
        CustomTooltip(
          message: SSG.getSSGBuildFolder(
              ssg: SSGTypes.values.byName(Preferences.getSSG())),
          child:
              OpenBuildButton(isExtended: navigationSizeProvider.isExtendedNav),
        ),
        divider(),
        CustomTooltip(
          message: Provider.of<OutputProvider>(context).showOutput
              ? Localization.appLocalizations().hideTerminalOutput
              : Localization.appLocalizations().showTerminalOutput,
          child: TerminalOutputButton(
              isExtended: navigationSizeProvider.isExtendedNav),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<NavigationSizeProvider>(
          builder: (context, navigationSizeProvider, _) {
        final windowWidth = MediaQuery.of(context).size.width;
        final navigationSize = navigationSizeProvider.navigationWidth;
        final fileNavigationSize = navigationSizeProvider.fileNavigationWidth;
        final editingPageSize =
            windowWidth - (navigationSize + fileNavigationSize);

        var finalSize = navigationSize;
        if (editingPageSize < 250 || windowWidth < mobileWidth) {
          if (navigationSize > 64) {
            finalSize = 200;
            lastWidth = 200;
            navigationSizeProvider.setNavigationWidth(200, notify: false);
          } else {
            finalSize = 64;
          }
        } else {
          finalSize = navigationSize;
        }

        return Stack(
          children: [
            Container(
              //AnimatedContainer
              //duration: const Duration(milliseconds: 250),
              //curve: Curves.easeInOut,
              //width: isExtended ? 256 : 64.0,
              width: (navigationSizeProvider.isExtendedNav
                      ? finalSize > 64
                          ? finalSize
                          : 200
                      : 64)
                  .toDouble(),
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 4.0, 6.0, 6.0),
                child: LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: navigationBarWidgets(
                                  navigationSizeProvider:
                                      navigationSizeProvider),
                            ),
                            Column(
                              children: [
                                divider(),
                                CustomTooltip(
                                  message:
                                      Localization.appLocalizations().settings,
                                  child: HomeNavigationButton(
                                    isExtended:
                                        navigationSizeProvider.isExtendedNav,
                                    icon: Icons.settings,
                                    iconUnselected: Icons.settings_outlined,
                                    buttonText: Localization.appLocalizations()
                                        .settings,
                                    page: NavigationPage.settings,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              //top: top + constraints.maxHeight / 2 - 30 / 2,
              top: 0,
              left: left + finalSize - 15 / 2,
              child: ResizeBar(
                maxHeight: constraints.maxHeight,
                onDrag: (dx, dy) {
                  var newWidth = navigationSizeProvider.navigationWidth +
                      (dx as double).toInt();
                  lastWidth = newWidth;

                  if (windowWidth > mobileWidth &&
                      editingPageSize < 300 &&
                      dx > 0) {
                  } else {
                    if (newWidth > 200) {
                      navigationSizeProvider.setNavigationWidth(newWidth);
                    } else {
                      if (dx > 3.0) {
                        navigationSizeProvider.setNavigationWidth(
                            newWidth > 200 ? newWidth : 200);
                        navigationSizeProvider.setIsExtendedNav(true);
                      } else {
                        navigationSizeProvider.setNavigationWidth(64);
                        navigationSizeProvider.setIsExtendedNav(false);
                      }
                    }
                  }
                },
                onEnd: () {
                  Preferences.setNavigationSize(finalSize);
                },
              ),
            ),
          ],
        );
      });
    });
  }
}
