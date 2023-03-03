import 'dart:io';

import 'package:buhocms/src/app.dart';
import 'package:buhocms/src/provider/navigation/navigation_provider.dart';
import 'package:buhocms/src/ssg/edit_frontmatter.dart';
import 'package:buhocms/src/utils/preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
//import 'package:buhocms/src/pages/onboarding_page.dart';
import 'package:buhocms/src/provider/app/theme_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../logic/buho_functions.dart';
import '../widgets/buttons/language_dropdown.dart';
import '../widgets/theme_selector.dart';
import 'editing_page.dart';
import 'onboarding_page.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    Key? key,
    required this.editingPageKey,
  }) : super(key: key);

  final GlobalKey<EditingPageState> editingPageKey;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsPage(editingPageKey: editingPageKey),
          ),
        );
      },
      icon: const Icon(Icons.settings),
      tooltip: AppLocalizations.of(context)!.settings,
      iconSize: 35,
      color: Colors.white,
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key? key,
    required this.editingPageKey,
  }) : super(key: key);

  final GlobalKey<EditingPageState> editingPageKey;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isExperimentalOptions = false;
  bool isMoreOptions = false;

  ScrollController listScrollController = ScrollController();

  TextStyle style = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );

  // Widget _experimentalTile() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 32.0),
  //     child: Column(
  //       children: const [],
  //     ),
  //   );
  // }

  Widget _moreTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Column(
        children: [
          _onboardingScreenTile(),
          _aboutTile(),
        ],
      ),
    );
  }

  Widget _headingTile(String text) {
    return ListTile(
      title: Text(
        text,
        style: style,
      ),
    );
  }

  Widget _aboutTile() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: Text(AppLocalizations.of(context)!.aboutBuhoCMS),
      onTap: () => about(context: context),
    );
  }

  // Widget _showExperimentalTile() {
  //   return InkWell(
  //     onTap: () => setState(() {
  //       isExperimentalOptions = !isExperimentalOptions;

  //       SchedulerBinding.instance.addPostFrameCallback((_) {
  //         listScrollController.animateTo(
  //           listScrollController.position.maxScrollExtent,
  //           duration: const Duration(milliseconds: 200),
  //           curve: Curves.easeInOut,
  //         );
  //       });
  //     }),
  //     child: ListTile(
  //       title: Text(
  //         isExperimentalOptions
  //             ? 'HIDE EXPERIMENTAL FEATURES'
  //             : 'SHOW EXPERIMENTAL FEATURES',
  //         style: style,
  //       ),
  //       trailing: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Icon(
  //           isExperimentalOptions ? Icons.expand_less : Icons.expand_more,
  //           size: 35,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _onboardingScreenTile() {
    return InkWell(
      onTap: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      ),
      child: ListTile(
        title: Text(AppLocalizations.of(context)!.onboardingScreen),
        subtitle: Text(
          AppLocalizations.of(context)!.onboardingScreen_description,
        ),
        trailing: const Icon(Icons.logout),
      ),
    );
  }

  Widget _showMoreTile() {
    return InkWell(
      onTap: () => setState(() {
        isMoreOptions = !isMoreOptions;

        SchedulerBinding.instance.addPostFrameCallback((_) {
          listScrollController.animateTo(
            listScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });
      }),
      child: ListTile(
        title: Text(
          isMoreOptions
              ? AppLocalizations.of(context)!.less
              : AppLocalizations.of(context)!.more,
          style: style,
        ),
        trailing: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            isMoreOptions ? Icons.expand_less : Icons.expand_more,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _openSiteTile() {
    return Consumer<NavigationProvider>(
        builder: (context, navigationProvider, _) {
      final sitePath = Preferences.getSitePath() ?? '';
      return ListTile(
        title: Text(AppLocalizations.of(context)!.openSite),
        subtitle: Text(
          AppLocalizations.of(context)!.currentSitePath(sitePath),
        ),
        trailing: ElevatedButton(
            onPressed: () => openHugoSite(context: context),
            child: Text(AppLocalizations.of(context)!.openSite)),
      );
    });
  }

  Widget _createSiteTile() {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.createSite),
      subtitle: Text(
        AppLocalizations.of(context)!.createSite_Description,
      ),
      trailing: ElevatedButton(
        onPressed: () => createHugoSite(context: context),
        child: Text(AppLocalizations.of(context)!.createSite),
      ),
    );
  }

  Widget _hugoThemeTile() {
    final theme = Preferences.getHugoTheme()
            .split(Platform.pathSeparator)
            .last
            .isEmpty
        ? 'N/A'
        : '"${Preferences.getHugoTheme().split(Platform.pathSeparator).last}"';
    return Consumer<NavigationProvider>(builder: (context, _, __) {
      return ListTile(
        title: Text(AppLocalizations.of(context)!.hugoThemes),
        subtitle: Text(
          AppLocalizations.of(context)!.currentHugoThemes(theme),
        ),
        trailing: ElevatedButton(
          onPressed: () => openHugoThemes(context: context),
          child: Text(AppLocalizations.of(context)!.hugoThemes),
        ),
      );
    });
  }

  Widget _themeTile() {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.theme),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.theme_description),
          const ThemeSelector(),
        ],
      ),
      trailing: Consumer<ThemeProvider>(builder: (context, value, _) {
        return DropdownButton(
          icon: Preferences.getThemeMode() == ThemeMode.system.name
              ? const Icon(Icons.settings_display)
              : Preferences.getThemeMode() == ThemeMode.light.name
                  ? const Icon(Icons.light_mode)
                  : const Icon(Icons.dark_mode),
          value: Themes.getThemeModeFromName(Preferences.getThemeMode()),
          items: [
            DropdownMenuItem(
              value: ThemeMode.system,
              onTap: () => Provider.of<ThemeProvider>(context, listen: false)
                  .setTheme(ThemeMode.system),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(AppLocalizations.of(context)!.themeSystem),
              ),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              onTap: () => Provider.of<ThemeProvider>(context, listen: false)
                  .setTheme(ThemeMode.light),
              child: Text(AppLocalizations.of(context)!.themeLight),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              onTap: () => Provider.of<ThemeProvider>(context, listen: false)
                  .setTheme(ThemeMode.dark),
              child: Text(AppLocalizations.of(context)!.themeDark),
            ),
          ],
          onChanged: (_) {},
        );
      }),
    );
  }

  void _reloadUI() {
    App.restartApp(context);
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetBuhoCMS),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Text(AppLocalizations.of(context)!.areYouSureResetBuhoCMS),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Preferences.clearPreferences();
              _reloadUI();
            },
            child: Text(AppLocalizations.of(context)!.yes),
          ),
        ],
      ),
    );
  }

  Widget _preferencesTile() {
    return Consumer<NavigationProvider>(builder: (context, _, __) {
      return ListTile(
        title: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.preferences),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String? outputFile = await FilePicker.platform.saveFile(
                      dialogTitle:
                          AppLocalizations.of(context)!.selectASavePath,
                      fileName: 'preferences.json',
                    );
                    if (outputFile == null) return;

                    if (File(outputFile).existsSync()) {
                      if (mounted) {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  AppLocalizations.of(context)!.overrideFile),
                              content: Text(
                                AppLocalizations.of(context)!
                                    .overrideFile_Description(outputFile
                                        .split(Platform.pathSeparator)
                                        .last),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                      AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final file =
                                        await File(outputFile).create();
                                    await file.writeAsString(
                                        Preferences.getAllPreferences());
                                    if (mounted) Navigator.pop(context);
                                  },
                                  child:
                                      Text(AppLocalizations.of(context)!.yes),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } else {
                      final file = await File(outputFile).create();
                      await file.writeAsString(Preferences.getAllPreferences());
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.export),
                ),
                //const VerticalDivider(),
                ElevatedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      initialDirectory: Preferences.getSitePath(),
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    );

                    if (result == null) return;
                    if (result.files.single.path == null) return;
                    final file = File(result.files.single.path!);
                    Preferences.setAllPreferences(file.readAsStringSync());
                    _reloadUI();
                  },
                  child: Text(AppLocalizations.of(context)!.import),
                ),
                //const VerticalDivider(),
                ElevatedButton(
                  onPressed: () => _showResetDialog(),
                  child: Text(AppLocalizations.of(context)!.reset),
                ),
              ],
            ),
          ],
        ),
        subtitle: Text(
          AppLocalizations.of(context)!.preferences_Description,
        ),
      );
    });
  }

  Widget _languageTile() {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.language),
      subtitle: Text(AppLocalizations.of(context)!.language_description),
      trailing: const LanguageDropdown(),
    );
  }

  Widget _editFrontmatterListTile() {
    return Consumer<NavigationProvider>(builder: (context, _, __) {
      return ListTile(
        title: Text(AppLocalizations.of(context)!.editFrontmatterList),
        subtitle: Text(
          AppLocalizations.of(context)!.editFrontmatterList_Description,
        ),
        trailing:
            EditFrontmatterListButton(editingPageKey: widget.editingPageKey),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() async {
        //await widget.onNewCameraSelected(widget.controller!.description);
        return true;
        //return true;
      }),
      child: Scaffold(
        appBar: AppBar(
            title: Row(
          children: [
            const SizedBox(width: 16),
            Text(AppLocalizations.of(context)!.settings),
          ],
        )),
        body: ListView(
          controller: listScrollController,
          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
          children: <Widget>[
            _headingTile(AppLocalizations.of(context)!.appSettings),
            _preferencesTile(),
            const Divider(),
            _languageTile(),
            const Divider(),
            _themeTile(),
            const Divider(),
            _headingTile(AppLocalizations.of(context)!.site),
            _openSiteTile(),
            const Divider(),
            _createSiteTile(),
            const Divider(),
            _hugoThemeTile(),
            const Divider(),
            _headingTile(AppLocalizations.of(context)!.hugoSettings),
            _editFrontmatterListTile(),
            // const Divider(),
            // _showExperimentalTile(),
            // if (isExperimentalOptions) _experimentalTile(),
            const Divider(),
            _showMoreTile(),
            if (isMoreOptions) _moreTile(),
          ],
        ),
      ),
    );
  }
}
