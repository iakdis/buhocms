import 'package:buhocms/src/pages/settings_page.dart';
import 'package:buhocms/src/provider/editing/editing_provider.dart';
import 'package:buhocms/src/provider/navigation/navigation_provider.dart';
import 'package:buhocms/src/widgets/file_navigation/files_navigation.dart';
import 'package:buhocms/src/widgets/home_navigation/home_navigation.dart';
import 'package:buhocms/src/pages/editing_page.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
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
  GlobalKey<EditingPageState> editingPageKey = GlobalKey<EditingPageState>();
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
      editingPageKey: editingPageKey,
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
    return Consumer<EditingProvider>(
      builder: (_, editingProvider, __) {
        return EditingPage(
          isGUIMode: editingProvider.isGUIMode,
          key: editingPageKey,
          editingPageKey: editingPageKey,
          focusNodePage: focusNodePage,
        );
      },
    );
  }

  Widget buildPages({required int index}) {
    switch (index) {
      case 0:
        return _editingPage();
      case 1:
        return SettingsPage(editingPageKey: editingPageKey);
      default:
        return _editingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    Localization.init(context);

    //final navigationProvider = Provider.of<NavigationProvider>(context);
    var windowWidth = MediaQuery.of(context).size.width;

    return CustomMenuBar(
      editingPageKey: editingPageKey,
      close: windowManager.destroy,
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
                          HomeNavigationDrawer(editingPageKey: editingPageKey),
                          FilesNavigationDrawer(editingPageKey: editingPageKey),
                          Expanded(
                            child: Consumer<NavigationProvider>(
                              builder: (_, navigationProvider, __) {
                                return buildPages(
                                    index: navigationProvider.navigationIndex ??
                                        0);
                              },
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
                          builder: (_, navigationProvider, __) {
                            return buildPages(
                                index: navigationProvider.navigationIndex ?? 0);
                          },
                        ),
                      ),
                      Row(
                        children: [
                          HomeNavigationDrawer(editingPageKey: editingPageKey),
                          FilesNavigationDrawer(editingPageKey: editingPageKey),
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
