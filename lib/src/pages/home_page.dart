import 'package:buhocms/src/pages/settings_page.dart';
import 'package:buhocms/src/provider/editing/editing_provider.dart';
import 'package:buhocms/src/provider/navigation/navigation_provider.dart';
import 'package:buhocms/src/widgets/file_navigation/files_navigation.dart';
import 'package:buhocms/src/widgets/home_navigation/home_navigation.dart';
import 'package:buhocms/src/pages/editing_page.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:menu_bar/menu_bar.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../i18n/l10n.dart';
import '../logic/buho_functions.dart';
import '../utils/globals.dart';
import '../widgets/menu_bar.dart';
import '../widgets/terminal_output_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  bool closingWindow = false;
  late FocusNode focusNodePage;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
    focusNodePage = FocusNode();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    focusNodePage.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (closingWindow) return;

    exit(
      context: context,
      close: () async {
        closingWindow = false;
        if (mounted) {
          Navigator.of(context).pop();
          await windowManager.destroy();
        }
      },
      setClosingWindow: (close) => closingWindow = close,
    );
  }

  Widget _editingPage() {
    final editingProvider = context.watch<EditingProvider>();
    return EditingPage(
      isGUIMode: editingProvider.isGUIMode,
      key: editingProvider.editingPageKey,
      focusNodePage: focusNodePage,
    );
  }

  Widget buildPages({required NavigationPage page}) {
    switch (page) {
      case NavigationPage.editing:
        return _editingPage();
      case NavigationPage.settings:
        return const SettingsPage();
      default:
        return _editingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    Localization.init(context);

    final windowWidth = MediaQuery.of(context).size.width;

    return MenuBarWidget(
      barButtons: getMenuBarMenus(
          context: context, mounted: mounted, close: windowManager.destroy),
      barStyle: const MenuStyle(
        padding: MaterialStatePropertyAll(EdgeInsets.zero),
        backgroundColor: MaterialStatePropertyAll(Color(0xFF2b2b2b)),
        maximumSize: MaterialStatePropertyAll(Size(double.infinity, 28.0)),
      ),
      barButtonStyle: const ButtonStyle(
        padding:
            MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 6.0)),
        minimumSize: MaterialStatePropertyAll(Size(0.0, 32.0)),
      ),
      menuButtonStyle: const ButtonStyle(
        minimumSize: MaterialStatePropertyAll(Size.fromHeight(28.0)),
      ),
      child: ContextMenuOverlay(
        child: GestureDetector(
          onTapDown: (_) => focusNodePage.requestFocus(),
          child: Scaffold(
            body: Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: windowWidth >= mobileWidth
                  ? [
                      Row(
                        children: [
                          const HomeNavigationDrawer(),
                          const FilesNavigationDrawer(),
                          Expanded(
                            child: Consumer<NavigationProvider>(
                              builder: (_, navigationProvider, __) =>
                                  buildPages(
                                      page: navigationProvider.navigationPage ??
                                          NavigationPage.editing),
                            ),
                          ),
                        ],
                      ),
                      const TerminalOutputDrawer(),
                    ]
                  : [
                      Padding(
                        padding: const EdgeInsets.only(left: 128.0),
                        child: Consumer<NavigationProvider>(
                          builder: (_, navigationProvider, __) => buildPages(
                              page: navigationProvider.navigationPage ??
                                  NavigationPage.editing),
                        ),
                      ),
                      const Row(
                        children: [
                          HomeNavigationDrawer(),
                          FilesNavigationDrawer(),
                        ],
                      ),
                      const TerminalOutputDrawer(),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
