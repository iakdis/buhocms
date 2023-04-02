import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:buhocms/src/widgets/buttons/language_dropdown.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:window_manager/window_manager.dart';

import '../i18n/l10n.dart';
import '../provider/app/theme_provider.dart';
import '../ssg/hugo.dart';
import '../ssg/ssg.dart';
import '../utils/preferences.dart';
import 'home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with WindowListener {
  final controller = PageController();
  bool isLastPage = false;

  int currentPage = 0;
  late FocusNode focusNode;

  TextStyle textStyle = TextStyle(
      color: Colors.teal.shade800, fontSize: 17.0, fontWeight: FontWeight.w500);

  @override
  void initState() {
    windowManager.addListener(this);

    focusNode = FocusNode();
    super.initState();
  }

  @override
  void onWindowClose() async => await windowManager.destroy();

  void previousPage() {
    focusNode.unfocus();
    controller.previousPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    unfocusAndRestore();
  }

  void nextPage() {
    focusNode.unfocus();
    controller.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    unfocusAndRestore();
  }

  bool backEnabled() {
    if (currentPage == 0) {
      return false;
    } else if (currentPage == 1) {
      return true;
    } else if (currentPage == 2) {
      return true;
    }

    return false;
  }

  bool nextEnabled() {
    if (currentPage == 0) {
      if (Preferences.getSitePath() == null) return false;
      if (Preferences.getSitePath()!.isEmpty) return false;
    }

    return true;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _websitePage() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.lightBlue.shade100,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 64.0,
        children: [
          _websitePageInfo(),
          _websitePageButtons(),
        ],
      ),
    );
  }

  Widget _websitePageInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const LanguageDropdown(),
        const SizedBox(height: 24.0),
        Text(
          Localization.appLocalizations().welcomeToBuhoCMS,
          style: TextStyle(
            color: Colors.teal.shade800,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Alpha (0.5.0)', // TODO update version number
          style: TextStyle(
            color: Colors.teal.shade800,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24.0),
        Icon(
          Icons.web,
          size: 100,
          color: Colors.teal.shade700,
        ),
        const SizedBox(height: 24.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            Localization.appLocalizations().welcomeToBuhoCMS_Description,
            style: textStyle,
          ),
        ),
      ],
    );
  }

  Widget _websitePageButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () =>
              createWebsite(context: context, setState: () => setState(() {})),
          child: Text(Localization.appLocalizations().createSite),
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: () =>
              openWebsite(context: context, setState: () => setState(() {})),
          child: Text(Localization.appLocalizations().openSite),
        ),
        const SizedBox(height: 48.0),
        Text(
          Preferences.getSitePath() == null ||
                  (Preferences.getSitePath()?.isEmpty ?? false)
              ? Localization.appLocalizations().websiteSelected('N/A')
              : Localization.appLocalizations()
                  .websiteSelected('\n"${Preferences.getSitePath()}"'),
          style: textStyle,
        ),
      ],
    );
  }

  Widget _themePage() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.orange.shade100,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 64.0,
        children: [
          _themePageInfo(),
          _themePageButtons(),
        ],
      ),
    );
  }

  Widget _themePageInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Localization.appLocalizations().themes,
          style: TextStyle(
            color: Colors.teal.shade800,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24.0),
        Icon(
          Icons.color_lens,
          size: 100,
          color: Colors.teal.shade700,
        ),
        const SizedBox(height: 24.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            Localization.appLocalizations().themes_Description,
            style: textStyle,
          ),
        ),
      ],
    );
  }

  Widget _themePageButtons() {
    final ssg = SSGTypes.values.byName(Preferences.getSSG());
    final theme = Hugo.getHugoTheme();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: ssg != SSGTypes.hugo
              ? Localization.appLocalizations().themesAvailableFor('Hugo')
              : '',
          child: ElevatedButton(
            onPressed: ssg == SSGTypes.hugo
                ? () => openHugoThemes(context: context)
                : null,
            child: Text(Localization.appLocalizations().websiteThemes),
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          Hugo.getHugoTheme().isEmpty
              ? Localization.appLocalizations().hugoThemeSelected('N/A')
              : Localization.appLocalizations().hugoThemeSelected('"$theme"'),
          style: textStyle,
        ),
      ],
    );
  }

  Widget _welcomePageInfo() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.green.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Localization.appLocalizations().allDone,
            style: TextStyle(
              color: Colors.teal.shade800,
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          Icon(
            Icons.handshake,
            size: 100,
            color: Colors.teal.shade700,
          ),
          const SizedBox(height: 24.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              Localization.appLocalizations().allDone_Description,
              style: textStyle,
            ),
          ),
          const SizedBox(height: 48.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Preferences.getSitePath() == null ||
                      (Preferences.getSitePath()?.isEmpty ?? false)
                  ? Icons.close
                  : Icons.check),
              Flexible(
                child: Text(
                  Preferences.getSitePath() == null ||
                          (Preferences.getSitePath()?.isEmpty ?? false)
                      ? Localization.appLocalizations().sitePath('N/A')
                      : Localization.appLocalizations()
                          .sitePath(Preferences.getSitePath() ?? 'N/A'),
                  style: textStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Hugo.getHugoTheme().isEmpty ? Icons.close : Icons.check),
              Flexible(
                child: Text(
                  Hugo.getHugoTheme().isEmpty
                      ? Localization.appLocalizations().hugoTheme('N/A')
                      : Localization.appLocalizations()
                          .hugoTheme(Hugo.getHugoTheme()),
                  style: textStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _welcomePageBottomButton() {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: Colors.teal.shade800,
        minimumSize: const Size.fromHeight(88.0),
      ),
      child: Text(
        Localization.appLocalizations().getStarted,
        style: const TextStyle(fontSize: 24.0),
      ),
      onPressed: () {
        Preferences.setOnBoardingComplete(true);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
    );
  }

  Widget _bottomPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 80.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: backEnabled() ? previousPage : null,
            child: Text(Localization.appLocalizations().back),
          ),
          Center(
            child: SmoothPageIndicator(
              controller: controller,
              count: 3,
              effect: WormEffect(
                  spacing: 16.0,
                  dotColor: Colors.black26,
                  activeDotColor: Colors.teal.shade800),
            ),
          ),
          TextButton(
            onPressed: nextEnabled() ? nextPage : null,
            child: Text(Localization.appLocalizations().next),
          ),
        ],
      ),
    );
  }

  void unfocusAndRestore() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
      SystemChrome.restoreSystemUIOverlays();
    }
  }

  Widget _scrollableChild(Widget child) {
    final ScrollController scrollController = ScrollController();
    return LayoutBuilder(builder: (context, constraints) {
      return ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          controller: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Localization.init(context);

    return Theme(
      data: Themes(Preferences.getColorSchemeIndex()).lightTheme(),
      child: GestureDetector(
        onTapDown: (details) => unfocusAndRestore(),
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                },
              ),
              child: PageView(
                physics: nextEnabled()
                    ? const ScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                controller: controller,
                onPageChanged: (index) {
                  setState(() {
                    isLastPage = index == 2;
                    currentPage = index;

                    unfocusAndRestore();
                  });
                },
                children: [
                  _scrollableChild(_websitePage()),
                  _scrollableChild(_themePage()),
                  _scrollableChild(_welcomePageInfo()),
                ],
              ),
            ),
          ),
          bottomSheet:
              isLastPage ? _welcomePageBottomButton() : _bottomPageIndicator(),
        ),
      ),
    );
  }
}
