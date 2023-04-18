import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_bar/menu_bar.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../i18n/l10n.dart';
import '../logic/buho_functions.dart';
import '../provider/navigation/navigation_provider.dart';
import '../ssg/ssg.dart';
import '../utils/preferences.dart';

List<BarButton> getMenuBarMenus({
  required BuildContext context,
  required bool mounted,
  required Function close,
}) {
  Text barButtonText(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Color(0xFFE9E9E9), fontWeight: FontWeight.normal),
    );
  }

  Text menuButtonText(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.normal),
    );
  }

  return [
    BarButton(
      text: barButtonText(Localization.appLocalizations().file),
      submenu: SubMenu(
        menuItems: [
          MenuButton(
            onTap: () => save(context: context),
            icon: const Icon(Icons.save),
            text: menuButtonText(Localization.appLocalizations().save),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyS, control: true),
            shortcutText: 'Ctrl+S',
          ),
          MenuButton(
            onTap: () => revert(context: context, mounted: mounted),
            icon: const Icon(Icons.undo),
            text: menuButtonText(Localization.appLocalizations().revertChanges),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyU, control: true),
            shortcutText: 'Ctrl+U',
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () => addFile(
              context: context,
              mounted: mounted,
            ),
            icon: const Icon(Icons.add),
            text: menuButtonText(Localization.appLocalizations().newPost),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyN, control: true),
            shortcutText: 'Ctrl+N',
          ),
          MenuButton(
            onTap: () => addFolder(
              context: context,
              mounted: mounted,
              setStateCallback: () {
                Provider.of<NavigationProvider>(context, listen: false)
                    .notifyAllListeners();
              },
            ),
            icon: const Icon(Icons.create_new_folder_outlined),
            text: menuButtonText(Localization.appLocalizations().newFolder),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () => openWebsite(context: context),
            icon: const Icon(Icons.folder_open),
            text: menuButtonText(Localization.appLocalizations().openSite),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyO, control: true),
            shortcutText: 'Ctrl+O',
          ),
          MenuButton(
            onTap: () => createWebsite(context: context),
            icon: const Icon(Icons.create_new_folder),
            text: menuButtonText(Localization.appLocalizations().createSite),
            shortcut: const SingleActivator(LogicalKeyboardKey.keyN,
                shift: true, control: true),
            shortcutText: 'Ctrl+Shift+N',
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () => startLiveServer(context: context),
            icon: const Icon(Icons.miscellaneous_services_rounded),
            text:
                menuButtonText(Localization.appLocalizations().startLiveServer),
          ),
          MenuButton(
            onTap: () => stopSSGServer(
                context: context,
                ssg: SSG.getSSGName(SSG.getSSGType(Preferences.getSSG()))),
            icon: const Icon(Icons.stop_circle_outlined),
            text:
                menuButtonText(Localization.appLocalizations().stopLiveServer),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () => buildWebsite(context: context),
            icon: const Icon(Icons.web),
            text: menuButtonText(Localization.appLocalizations().buildWebsite(
                SSG.getSSGName(SSG.getSSGType(Preferences.getSSG())))),
          ),
          MenuButton(
            onTap: () => openBuildFolder(),
            icon: const Icon(Icons.folder_open),
            text:
                menuButtonText(Localization.appLocalizations().openBuildFolder),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () => exit(
              context: context,
              close: close,
            ),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
            shortcutText: 'Ctrl+Q',
            text: menuButtonText(Localization.appLocalizations().exit),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
    ),
    BarButton(
      text: barButtonText(Localization.appLocalizations().edit),
      submenu: SubMenu(
        menuItems: [
          MenuButton(
            onTap: () => refreshFiles(context: context),
            icon: const Icon(Icons.refresh),
            text: menuButtonText(Localization.appLocalizations().refreshFiles),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyR, control: true),
            shortcutText: 'Ctrl+R',
          ),
          MenuButton(
            onTap: () => openCurrentPathInFolder(
                path: Preferences.getCurrentPath(), keepPathTrailing: true),
            icon: const Icon(Icons.open_in_new),
            text: menuButtonText(
                Localization.appLocalizations().openCurrentFileInExplorer),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () => setGUIMode(
              context: context,
              isGUIMode: true,
            ),
            icon: const Icon(Icons.table_chart),
            text: menuButtonText(Localization.appLocalizations().guiMode),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyG, control: true),
            shortcutText: 'Ctrl+G',
          ),
          MenuButton(
            onTap: () => setGUIMode(
              context: context,
              isGUIMode: false,
            ),
            icon: const Icon(Icons.text_snippet_outlined),
            text: menuButtonText(Localization.appLocalizations().textMode),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyT, control: true),
            shortcutText: 'Ctrl+T',
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () => fullScreen(windowManager),
            icon: const Icon(Icons.fullscreen),
            text: menuButtonText(Localization.appLocalizations().fullScreen),
            shortcut: const SingleActivator(LogicalKeyboardKey.f11),
            shortcutText: 'F11',
          ),
          MenuButton(
            onTap: () async => await windowManager.setFullScreen(false),
            icon: const Icon(Icons.fullscreen_exit),
            text:
                menuButtonText(Localization.appLocalizations().exitFullScreen),
            shortcut: const SingleActivator(LogicalKeyboardKey.escape),
            shortcutText: 'ESC',
          ),
        ],
      ),
    ),
    BarButton(
      text: barButtonText(Localization.appLocalizations().help),
      submenu: SubMenu(
        menuItems: [
          MenuButton(
            onTap: () => openHomepage(),
            icon: const Icon(Icons.open_in_new),
            text: menuButtonText(Localization.appLocalizations().openHomepage),
          ),
          MenuButton(
            onTap: () => reportIssue(),
            icon: const Icon(Icons.bug_report),
            text: menuButtonText(Localization.appLocalizations().reportIssue),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () => about(context: context),
            icon: const Icon(Icons.info),
            text: menuButtonText(Localization.appLocalizations().about),
          ),
        ],
      ),
    ),
  ];
}
