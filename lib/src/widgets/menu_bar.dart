import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

import '../logic/buho_functions.dart';
import '../pages/editing_page.dart';
import '../provider/navigation/navigation_provider.dart';
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
            minimumSize: MaterialStatePropertyAll(Size(0.0, 64.0)),
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
    required this.editingPageKey,
    required this.close,
  });

  final Widget child;
  final GlobalKey<EditingPageState> editingPageKey;
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
          context: context,
          text: AppLocalizations.of(context)!.fullScreenInfo,
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
        text: barButtonText(AppLocalizations.of(context)!.file),
        menuChildren: [
          MenuButton(
            onPressed: () =>
                save(context: context, editingPageKey: widget.editingPageKey),
            icon: const Icon(Icons.save),
            text: menuButtonText(AppLocalizations.of(context)!.save),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyS, control: true),
            shortcutText: 'Ctrl+S',
          ),
          MenuButton(
            onPressed: () => revert(
                context: context,
                editingPageKey: widget.editingPageKey,
                mounted: mounted),
            icon: const Icon(Icons.undo),
            text: menuButtonText(AppLocalizations.of(context)!.revertChanges),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyU, control: true),
            shortcutText: 'Ctrl+U',
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => addFile(
              context: context,
              mounted: mounted,
              editingPageKey: widget.editingPageKey,
            ),
            icon: const Icon(Icons.add),
            text: menuButtonText(AppLocalizations.of(context)!.newPost),
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
              editingPageKey: widget.editingPageKey,
            ),
            icon: const Icon(Icons.create_new_folder_outlined),
            text: menuButtonText(AppLocalizations.of(context)!.newFolder),
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => openHugoSite(context: context),
            icon: const Icon(Icons.folder_open),
            text: menuButtonText(AppLocalizations.of(context)!.openSite),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyO, control: true),
            shortcutText: 'Ctrl+O',
          ),
          MenuButton(
            onPressed: () => createHugoSite(context: context),
            icon: const Icon(Icons.create_new_folder),
            text: menuButtonText(AppLocalizations.of(context)!.createSite),
            shortcut: const SingleActivator(LogicalKeyboardKey.keyN,
                shift: true, control: true),
            shortcutText: 'Ctrl+Shift+N',
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => startHugoServer(context: context),
            icon: const Icon(Icons.miscellaneous_services_rounded),
            text: menuButtonText(AppLocalizations.of(context)!.startHugoServer),
          ),
          MenuButton(
            onPressed: () => stopHugoServer(context: context),
            icon: const Icon(Icons.stop_circle_outlined),
            text: menuButtonText(AppLocalizations.of(context)!.stopHugoServer),
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => buildHugoSite(context: context),
            icon: const Icon(Icons.web),
            text: menuButtonText(AppLocalizations.of(context)!.buildHugoSite),
          ),
          MenuButton(
            onPressed: () => openHugoPublicFolder(context: context),
            icon: const Icon(Icons.folder_open),
            text:
                menuButtonText(AppLocalizations.of(context)!.openPublicFolder),
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => exit(
              context: context,
              editingPageKey: widget.editingPageKey,
              close: widget.close,
            ),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
            shortcutText: 'Ctrl+Q',
            text: menuButtonText(AppLocalizations.of(context)!.exit),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      MenuButton(
        text: barButtonText(AppLocalizations.of(context)!.edit),
        menuChildren: [
          MenuButton(
            onPressed: () => refreshFiles(context: context),
            icon: const Icon(Icons.refresh),
            text: menuButtonText(AppLocalizations.of(context)!.refreshFiles),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyR, control: true),
            shortcutText: 'Ctrl+R',
          ),
          MenuButton(
            onPressed: () => openCurrentPathInFolder(
                path: Preferences.getCurrentPath(), keepPathTrailing: true),
            icon: const Icon(Icons.open_in_new),
            text: menuButtonText(
                AppLocalizations.of(context)!.openCurrentFileInExplorer),
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => setGUIMode(
              context: context,
              editingPageKey: widget.editingPageKey,
              isGUIMode: true,
            ),
            icon: const Icon(Icons.table_chart),
            text: menuButtonText(AppLocalizations.of(context)!.guiMode),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyG, control: true),
            shortcutText: 'Ctrl+G',
          ),
          MenuButton(
            onPressed: () => setGUIMode(
              context: context,
              editingPageKey: widget.editingPageKey,
              isGUIMode: false,
            ),
            icon: const Icon(Icons.text_snippet_outlined),
            text: menuButtonText(AppLocalizations.of(context)!.textMode),
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyT, control: true),
            shortcutText: 'Ctrl+T',
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => fullScreen(),
            icon: const Icon(Icons.fullscreen),
            text: menuButtonText(AppLocalizations.of(context)!.fullScreen),
            shortcut: const SingleActivator(LogicalKeyboardKey.f11),
            shortcutText: 'F11',
          ),
          MenuButton(
            onPressed: () async => await windowManager.setFullScreen(false),
            icon: const Icon(Icons.fullscreen_exit),
            text: menuButtonText(AppLocalizations.of(context)!.exitFullScreen),
            shortcut: const SingleActivator(LogicalKeyboardKey.escape),
            shortcutText: 'ESC',
          ),
        ],
      ),
      MenuButton(
        text: barButtonText(AppLocalizations.of(context)!.help),
        menuChildren: [
          MenuButton(
            onPressed: () => openHomepage(),
            icon: const Icon(Icons.open_in_new),
            text: menuButtonText(AppLocalizations.of(context)!.openHomepage),
          ),
          MenuButton(
            onPressed: () => reportIssue(),
            icon: const Icon(Icons.bug_report),
            text: menuButtonText(AppLocalizations.of(context)!.reportIssue),
          ),
          const MenuDivider(),
          MenuButton(
            onPressed: () => about(context: context),
            icon: const Icon(Icons.info),
            text: menuButtonText(AppLocalizations.of(context)!.about),
          ),
        ],
      ),
    ];
    _shortcutsEntry?.dispose();
    _shortcutsEntry =
        ShortcutRegistry.of(context).addAll(MenuEntry.shortcuts(result));
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
