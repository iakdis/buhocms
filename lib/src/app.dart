import 'package:buhocms/src/i18n/l10n.dart';
import 'package:buhocms/src/pages/home_page.dart';
import 'package:buhocms/src/pages/onboarding_page.dart';
import 'package:buhocms/src/provider/app/output_provider.dart';
import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:buhocms/src/provider/app/ssg_provider.dart';
import 'package:buhocms/src/provider/editing/editing_provider.dart';
import 'package:buhocms/src/provider/navigation/file_navigation_provider.dart';
import 'package:buhocms/src/provider/app/locale_provider.dart';
import 'package:buhocms/src/provider/navigation/navigation_provider.dart';
import 'package:buhocms/src/provider/navigation/navigation_size_provider.dart';
import 'package:buhocms/src/provider/editing/tabs_provider.dart';
import 'package:buhocms/src/provider/app/theme_provider.dart';
import 'package:buhocms/src/provider/editing/unsaved_text_provider.dart';
import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

class App extends StatefulWidget {
  const App({super.key});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppState>()?.restartApp();
  }

  @override
  State<App> createState() => _AppState();
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _AppState extends State<App> with WindowListener {
  Key key = UniqueKey();

  @override
  void initState() {
    windowManager.addListener(this);
    windowManager.setMinimumSize(const Size(400, 200));
    windowManager.setTitle('BuhoCMS');
    super.initState();
  }

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SSGProvider()),
          ChangeNotifierProvider(create: (context) => OutputProvider()),
          ChangeNotifierProvider(create: (context) => ShellProvider()),
          ChangeNotifierProvider(create: (context) => TabsProvider()),
          ChangeNotifierProvider(create: (context) => NavigationSizeProvider()),
          ChangeNotifierProvider(create: (context) => UnsavedTextProvider()),
          ChangeNotifierProvider(create: (context) => EditingProvider()),
          ChangeNotifierProvider(create: (context) => NavigationProvider()),
          ChangeNotifierProvider(create: (context) => FileNavigationProvider()),
          ChangeNotifierProvider(create: (context) => LocaleProvider()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        builder: ((_, __) {
          return Consumer2<LocaleProvider, ThemeProvider>(
            builder: (_, localeProvider, themeProvider, __) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                scaffoldMessengerKey: rootScaffoldMessengerKey,
                title: 'BuhoCMS',
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.themeMode(),
                theme: Themes(themeProvider.colorSchemeIndex()).lightTheme(),
                darkTheme: Themes(themeProvider.colorSchemeIndex()).darkTheme(),
                locale: localeProvider.locale,
                supportedLocales: Localization.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: Preferences.getOnBoardingComplete()
                    ? const HomePage()
                    : const OnboardingPage(),
              );
            },
          );
        }),
      ),
    );
  }
}
