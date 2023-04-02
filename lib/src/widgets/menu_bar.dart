import 'package:buhocms/src/widgets/shortcuts.dart';
import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../i18n/l10n.dart';
import '../logic/buho_functions.dart';
import '../provider/navigation/navigation_provider.dart';
import '../ssg/ssg.dart';
import '../utils/preferences.dart';

class MenuButton extends MenuEntry {
  const MenuButton({
    super.text,
    super.icon,
    super.shortcut,
    super.shortcutText,
    super.onPressed,
    super.menuChildren,
  }) : super(isDivider: false);
}

class MenuDivider extends MenuEntry {
  const MenuDivider()
      : super(
          isDivider: true,
          text: null,
          icon: null,
          shortcut: null,
          shortcutText: null,
          onPressed: null,
          menuChildren: null,
        );
}

class MenuEntry {
  const MenuEntry({
    required this.text,
    this.icon,
    this.shortcut,
    this.shortcutText,
    this.onPressed,
    this.menuChildren,
    this.isDivider = false,
  }) : assert(menuChildren == null || onPressed == null,
            'onPressed is ignored if menuChildren are provided');
  final Text? text;
  final Widget? icon;
  final MenuSerializableShortcut? shortcut;
  final String? shortcutText;
  final VoidCallback? onPressed;
  final List<MenuEntry>? menuChildren;
  final bool isDivider;

  static List<Widget> build(List<MenuEntry> selections) {
    Widget buildSelection(MenuEntry selection) {
      if (selection.isDivider) {
        return const Divider();
      }

      if (selection.menuChildren != null) {
        return SubmenuButton(
          style: const ButtonStyle(
            padding:
                MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 6.0)),
            minimumSize: MaterialStatePropertyAll(Size(0.0, 32.0)),
          ),
          menuChildren: MenuEntry.build(selection.menuChildren!),
          child: selection.text,
        );
      }
      return MenuItemButton(
        style: const ButtonStyle(
          minimumSize: MaterialStatePropertyAll(Size.fromHeight(28.0)),
        ),
        leadingIcon: selection.icon,
        trailingIcon: selection.shortcutText != null
            ? Text(selection.shortcutText!,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ))
            : null,
        onPressed: selection.onPressed,
        child: selection.text,
      );
    }

    return selections.map<Widget>(buildSelection).toList();
  }

  static Map<MenuSerializableShortcut, Intent> shortcuts(
      List<MenuEntry> selections) {
    final Map<MenuSerializableShortcut, Intent> result =
        <MenuSerializableShortcut, Intent>{};
    for (final MenuEntry selection in selections) {
      if (selection.menuChildren != null) {
        result.addAll(MenuEntry.shortcuts(selection.menuChildren!));
      } else {
        if (selection.shortcut != null && selection.onPressed != null) {
          result[selection.shortcut!] =
              VoidCallbackIntent(selection.onPressed!);
        }
      }
    }
    return result;
  }
}

class CustomMenuBar extends StatefulWidget {
  const CustomMenuBar({
    super.key,
    required this.child,
    required this.close,
  });

  final Widget child;
  final Function close;

  @override
  State<CustomMenuBar> createState() => _CustomMenuBarState();
}

class _CustomMenuBarState extends State<CustomMenuBar> {
  ShortcutRegistryEntry? _shortcutsEntry;

  void fullScreen() async {
    final isFullScreen = await windowManager.isFullScreen();
    if (!isFullScreen) {
      await windowManager.setFullScreen(true);
      if (mounted) {
        showSnackbar(
          text: Localization.appLocalizations().fullScreenInfo,
          seconds: 3,
        );
      }
    } else {
      await windowManager.setFullScreen(false);
    }
  }

  List<MenuEntry> _getMenus() {
    Text barButtonText(String text) {
      return Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE9E9E9),
          fontWeight: FontWeight.normal,
        ),
      );
    }

    Text menuButtonText(String text) {
      return Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
        ),
      );
    }

    final List<MenuEntry> result = <MenuEntry>[
      MenuButton(
        text: barButtonText(Localization.appLocalizations().file),
        menuChildren: [
          MenuButton(
            onPressed: () => save(context: context),
            icon: const Icon(Icons.save),
            text: menuButtonText(Localization.appLocalizations().save),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyS, control: true),
            shortcutText: 'Ctrl+S',
          ),
          MenuButton(
            onPressed: () => revert(context: context, mounted: mounted),
            icon: const Icon(Icons.undo),
            text: menuButtonText(Localization.appLocalizations().revertChanges),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyU, control: true),
            shortcutText: 'Ctrl+U',
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => addFile(
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
            onPressed: () => addFolder(
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
            onPressed: () => openHugoSite(context: context),
            icon: const Icon(Icons.folder_open),
            text: menuButtonText(Localization.appLocalizations().openSite),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyO, control: true),
            shortcutText: 'Ctrl+O',
          ),
          MenuButton(
            onPressed: () => createHugoSite(context: context),
            icon: const Icon(Icons.create_new_folder),
            text: menuButtonText(Localization.appLocalizations().createSite),
            shortcut: const SingleActivator(LogicalKeyboardKey.keyN,
                shift: true, control: true),
            shortcutText: 'Ctrl+Shift+N',
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => startLiveServer(context: context),
            icon: const Icon(Icons.miscellaneous_services_rounded),
            text:
                menuButtonText(Localization.appLocalizations().startLiveServer),
          ),
          MenuButton(
            onPressed: () => stopSSGServer(context: context, ssg: 'Hugo'),
            icon: const Icon(Icons.stop_circle_outlined),
            text:
                menuButtonText(Localization.appLocalizations().stopLiveServer),
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => buildWebsite(context: context),
            icon: const Icon(Icons.web),
            text: menuButtonText(Localization.appLocalizations().buildWebsite(
                SSG.getSSGName(SSGTypes.values.byName(Preferences.getSSG())))),
          ),
          MenuButton(
            onPressed: () => openHugoPublicFolder(),
            icon: const Icon(Icons.folder_open),
            text:
                menuButtonText(Localization.appLocalizations().openBuildFolder),
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => exit(
              context: context,
              close: widget.close,
            ),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
            shortcutText: 'Ctrl+Q',
            text: menuButtonText(Localization.appLocalizations().exit),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      MenuButton(
        text: barButtonText(Localization.appLocalizations().edit),
        menuChildren: [
          MenuButton(
            onPressed: () => refreshFiles(context: context),
            icon: const Icon(Icons.refresh),
            text: menuButtonText(Localization.appLocalizations().refreshFiles),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyR, control: true),
            shortcutText: 'Ctrl+R',
          ),
          MenuButton(
            onPressed: () => openCurrentPathInFolder(
                path: Preferences.getCurrentPath(), keepPathTrailing: true),
            icon: const Icon(Icons.open_in_new),
            text: menuButtonText(
                Localization.appLocalizations().openCurrentFileInExplorer),
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => setGUIMode(
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
            onPressed: () => setGUIMode(
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
            onPressed: () => fullScreen(),
            icon: const Icon(Icons.fullscreen),
            text: menuButtonText(Localization.appLocalizations().fullScreen),
            shortcut: const SingleActivator(LogicalKeyboardKey.f11),
            shortcutText: 'F11',
          ),
          MenuButton(
            onPressed: () async => await windowManager.setFullScreen(false),
            icon: const Icon(Icons.fullscreen_exit),
            text:
                menuButtonText(Localization.appLocalizations().exitFullScreen),
            shortcut: const SingleActivator(LogicalKeyboardKey.escape),
            shortcutText: 'ESC',
          ),
        ],
      ),
      MenuButton(
        text: barButtonText(Localization.appLocalizations().help),
        menuChildren: [
          MenuButton(
            onPressed: () => openHomepage(),
            icon: const Icon(Icons.open_in_new),
            text: menuButtonText(Localization.appLocalizations().openHomepage),
          ),
          MenuButton(
            onPressed: () => reportIssue(),
            icon: const Icon(Icons.bug_report),
            text: menuButtonText(Localization.appLocalizations().reportIssue),
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => about(context: context),
            icon: const Icon(Icons.info),
            text: menuButtonText(Localization.appLocalizations().about),
          ),
        ],
      ),
    ];
    _shortcutsEntry?.dispose();
    _shortcutsEntry = ShortcutRegistry.of(context).addAll(
        MenuEntry.shortcuts(result)..addAll(markdownToolbarShortcuts(context)));

    return result;
  }

  @override
  void dispose() {
    _shortcutsEntry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: MenuBar(
                style: const MenuStyle(
                  padding: MaterialStatePropertyAll(EdgeInsets.zero),
                  backgroundColor: MaterialStatePropertyAll(Color(0xFF2b2b2b)),
                  maximumSize:
                      MaterialStatePropertyAll(Size(double.infinity, 28.0)),
                ),
                children: MenuEntry.build(_getMenus()),
              ),
            ),
          ],
        ),
        Expanded(
          child: widget.child,
        ),
      ],
    );
  }
}
