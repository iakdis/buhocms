import 'package:buhocms/src/pages/editing_page.dart';
import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:buhocms/src/utils/globals.dart';
import 'package:buhocms/src/utils/preferences.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/gui_mode_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/hugo_public_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/hugo_server_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/navigation_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/open_localhost_button.dart';
import 'package:buhocms/src/widgets/home_navigation/buttons/open_public_button.dart';
import 'package:buhocms/src/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../provider/navigation/navigation_size_provider.dart';
import '../resize_bar.dart';

class HomeNavigationDrawer extends StatefulWidget {
  const HomeNavigationDrawer({super.key, required this.editingPageKey});

  final GlobalKey<EditingPageState> editingPageKey;

  @override
  State<HomeNavigationDrawer> createState() => _HomeNavigationDrawerState();
}

class _HomeNavigationDrawerState extends State<HomeNavigationDrawer> {
  bool isExtended = false;

  double lastWidth = 64;

  double top = 0;
  double left = 0;

  @override
  void initState() {
    final navigationSizeProvider =
        Provider.of<NavigationSizeProvider>(context, listen: false);
    navigationSizeProvider.setNavigationWidth(
      Preferences.getNavigationSize(),
      notify: false,
    );
    lastWidth = Preferences.getNavigationSize();
    isExtended = navigationSizeProvider.navigationWidth > 64 ? true : false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var windowWidth = MediaQuery.of(context).size.width;
    var navigationSizeProvider = Provider.of<NavigationSizeProvider>(context);
    var navigationSize = navigationSizeProvider.navigationWidth;
    var fileNavigationSize = navigationSizeProvider.fileNavigationWidth;
    var editingPageSize = windowWidth - (navigationSize + fileNavigationSize);

    var finalSize = navigationSize;
    if (editingPageSize < 250 || windowWidth < mobileWidth) {
      if (navigationSize > 64) {
        finalSize = 200.0;
        lastWidth = 200;
        navigationSizeProvider.setNavigationWidth(200, notify: false);
      } else {
        finalSize = 64.0;
      }
    } else {
      finalSize = navigationSize;
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<NavigationSizeProvider>(
          builder: (context, navigationSizeProvider, _) {
        return Stack(
          children: [
            Container(
              //AnimatedContainer
              //duration: const Duration(milliseconds: 250),
              //curve: Curves.easeInOut,
              //width: isExtended ? 256 : 64.0,
              width: isExtended
                  ? finalSize > 64
                      ? finalSize
                      : 200
                  : 64.0,
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
                              children: [
                                Align(
                                  alignment: isExtended
                                      ? Alignment.centerRight
                                      : Alignment.center,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: Icon(
                                          isExtended
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          size: 48.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                        ),
                                      ),
                                      onTap: () => setState(() {
                                        if (isExtended) {
                                          isExtended = false;
                                          navigationSizeProvider
                                              .setNavigationWidth(64);
                                        } else {
                                          isExtended = true;
                                          navigationSizeProvider
                                              .setNavigationWidth(
                                                  lastWidth > 200
                                                      ? lastWidth
                                                      : 200);
                                        }
                                        Preferences.setNavigationSize(
                                            navigationSizeProvider
                                                .navigationWidth);
                                      }),
                                    ),
                                  ),
                                ),
                                Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                CustomTooltip(
                                  message:
                                      AppLocalizations.of(context)!.editingPage,
                                  child: NavigationButton(
                                    editingPageKey: widget.editingPageKey,
                                    isExtended: isExtended,
                                    icon: Icons.edit,
                                    iconUnselected: Icons.edit_outlined,
                                    buttonText: AppLocalizations.of(context)!
                                        .editingPage,
                                    index: 0,
                                  ),
                                ),
                                Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                CustomTooltip(
                                  message:
                                      AppLocalizations.of(context)!.guiMode,
                                  child: GUIModeButton(
                                      isExtended: isExtended,
                                      isGUIMode: true,
                                      editingPageKey: widget.editingPageKey),
                                ),
                                CustomTooltip(
                                  message:
                                      AppLocalizations.of(context)!.textMode,
                                  child: GUIModeButton(
                                      isExtended: isExtended,
                                      isGUIMode: false,
                                      editingPageKey: widget.editingPageKey),
                                ),
                                Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                CustomTooltip(
                                  message: Provider.of<ShellProvider>(context)
                                              .shellActive ==
                                          true
                                      ? AppLocalizations.of(context)!
                                          .stopHugoServer
                                      : AppLocalizations.of(context)!
                                          .startHugoServer,
                                  child:
                                      HugoServerButton(isExtended: isExtended),
                                ),
                                CustomTooltip(
                                  message: AppLocalizations.of(context)!
                                      .openHugoServer,
                                  child: OpenLocalhostButton(
                                      isExtended: isExtended),
                                ),
                                Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                CustomTooltip(
                                  message: AppLocalizations.of(context)!
                                      .buildHugoSite,
                                  child:
                                      HugoBuildButton(isExtended: isExtended),
                                ),
                                CustomTooltip(
                                  message: AppLocalizations.of(context)!
                                      .openPublicFolder,
                                  child:
                                      OpenPublicButton(isExtended: isExtended),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                CustomTooltip(
                                  message:
                                      AppLocalizations.of(context)!.settings,
                                  child: NavigationButton(
                                    editingPageKey: widget.editingPageKey,
                                    isExtended: isExtended,
                                    icon: Icons.settings,
                                    iconUnselected: Icons.settings_outlined,
                                    buttonText:
                                        AppLocalizations.of(context)!.settings,
                                    index: 1,
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
                  var newWidth = navigationSizeProvider.navigationWidth + dx;
                  lastWidth = newWidth;

                  var windowWidth = MediaQuery.of(context).size.width;
                  var navigationSize = navigationSizeProvider.navigationWidth;
                  var fileNavigationSize =
                      navigationSizeProvider.fileNavigationWidth;
                  var editingPageSize =
                      windowWidth - (navigationSize + fileNavigationSize);

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
                        isExtended = true;
                      } else {
                        navigationSizeProvider.setNavigationWidth(64);
                        isExtended = false;
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
