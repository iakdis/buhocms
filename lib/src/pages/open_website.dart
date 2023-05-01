import 'dart:io';

import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:buhocms/src/provider/app/ssg_provider.dart';
import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../i18n/l10n.dart';
import '../provider/app/shell_provider.dart';
import '../provider/navigation/file_navigation_provider.dart';
import '../provider/navigation/navigation_provider.dart';
import '../ssg/ssg.dart';
import '../utils/preferences.dart';

class OpenWebsite extends StatefulWidget {
  const OpenWebsite({super.key});

  @override
  State<OpenWebsite> createState() => _OpenWebsiteState();
}

class _OpenWebsiteState extends State<OpenWebsite> {
  int currentStep = 0;
  bool canContinue = false;

  String sitePath = Preferences.getSitePath() ?? '';
  SSGTypes currentSSG = SSG.getSSGType(Preferences.getSSG());
  bool sitePathError = false;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    textController.text = sitePath;
    textController.selection = TextSelection(
        baseOffset: textController.text.length,
        extentOffset: textController.text.length);
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void savePath() async {
    String? selectedDirectory = await FilePicker.platform
        .getDirectoryPath(initialDirectory: Preferences.getSitePath());

    if (selectedDirectory == null) {
      // User canceled the picker
    }

    await Preferences.setSitePath(
        selectedDirectory ?? Preferences.getSitePath() ?? '');
    final contentFolder = SSG.getSSGContentFolder(
        ssg: SSG.getSSGType(Preferences.getSSG()), pathSeparator: true);
    await Preferences.setCurrentPath(
        '${Preferences.getSitePath()}$contentFolder');

    setState(() {
      sitePathError = false;
      sitePath = Preferences.getSitePath() ?? '';
      textController.text = sitePath;
      textController.selection = TextSelection(
          baseOffset: textController.text.length,
          extentOffset: textController.text.length);
    });
  }

  void open({required String sitePath, required SSGTypes ssg}) {
    stopSSGServer(context: context, ssg: SSG.getSSGName(ssg), snackbar: false);

    Preferences.clearPreferencesSite();
    Preferences.setOnBoardingComplete(true);

    Preferences.setSitePath(sitePath);
    final contentFolder =
        SSG.getSSGContentFolder(ssg: ssg, pathSeparator: true);
    Preferences.setCurrentPath('${Preferences.getSitePath()}$contentFolder');
    final recentPaths = Preferences.getRecentSitePaths();
    final entries = recentPaths.entries.toList();
    final keys = recentPaths.keys.toList();

    if (keys.contains(sitePath)) {
      for (var i = 0; i < recentPaths.length; i++) {
        if (keys[i] == sitePath) entries.removeAt(i);
      }
    }
    Preferences.setRecentSitePaths({sitePath: ssg}..addAll(recentPaths));

    context.read<SSGProvider>().setSSG(ssg.name);

    Provider.of<ShellProvider>(context, listen: false).updateShell();

    Navigator.of(context).pop();
    context.read<NavigationProvider>().notifyAllListeners();
    context.read<FileNavigationProvider>().notifyAllListeners();
  }

  Widget stepper() {
    return Stepper(
      currentStep: currentStep,
      /*onStepTapped: canContinue
              ? (index) {
                  setState(() {
                    currentStep = index;
                  });
                }
              : null,*/
      onStepContinue: () async {
        if (currentStep == 0) {
          setState(() => currentStep++);
        } else if (currentStep == 1) {
          if (sitePath.isEmpty) {
            setState(() => sitePathError = true);
            return;
          }
          if (!Directory(sitePath).existsSync()) {
            showSnackbar(
              text: Localization.appLocalizations()
                  .error_DirectoryDoesNotExist('"$sitePath"'),
              seconds: 4,
            );
            return;
          }
          open(sitePath: sitePath, ssg: currentSSG);
        }
      },
      onStepCancel: () {
        if (currentStep > 0) {
          setState(() => currentStep--);
        }
      },
      controlsBuilder: (context, details) {
        canContinue = (details.stepIndex == 1 ? !sitePathError : true);

        return Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: canContinue ? details.onStepContinue : null,
                child: Text(details.stepIndex == 0
                    ? Localization.appLocalizations().continue2
                    : Localization.appLocalizations().open.toUpperCase()),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: details.stepIndex > 0 ? details.onStepCancel : null,
                child: Text(Localization.appLocalizations().back),
              ),
            ],
          ),
        );
      },
      steps: [
        Step(
          isActive: currentStep >= 0,
          title: Text(Localization.appLocalizations().checkStaticSiteStructure),
          content: Wrap(
            spacing: 128.0,
            runSpacing: 32.0,
            alignment: WrapAlignment.center,
            children: [
              Column(
                children: [
                  svg(
                    path:
                        'assets/images/${SSG.getSSGName(currentSSG).toLowerCase()}.svg',
                    size: 64,
                    semanticsLabel: Localization.appLocalizations()
                        .currentSSG(SSG.getSSGName(currentSSG)),
                  ),
                  const SizedBox(height: 32),
                  DropdownButton<SSGTypes>(
                    value: currentSSG,
                    items: SSGTypes.values
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(SSG.getSSGName(e))))
                        .toList(),
                    onChanged: (option) async {
                      if (option == null) return;
                      currentSSG = option;
                      setState(() {});
                    },
                  ),
                ],
              ),
              SizedBox(
                width: 500,
                child: SelectableText(
                  Localization.appLocalizations()
                      .checkStaticSiteStructure_Description,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        Step(
          isActive: currentStep >= 1,
          title: Text(Localization.appLocalizations().selectSiteFolder),
          content: Column(
            children: [
              ElevatedButton(
                  onPressed: savePath,
                  child: Text(Localization.appLocalizations().choosePath)),
              const SizedBox(height: 12.0),
              SizedBox(
                width: 400,
                child: TextField(
                  onChanged: (value) {
                    var end = textController.text.length;
                    if (textController.text.isNotEmpty &&
                        textController.text[textController.text.length - 1] ==
                            Platform.pathSeparator) {
                      end = textController.text.length - 1;
                    }
                    sitePath = sitePath = textController.text.substring(0, end);
                    sitePathError = false;
                    setState(() {});
                  },
                  controller: textController,
                  style: TextStyle(color: Colors.grey[600], fontSize: 17.0),
                  decoration: InputDecoration(
                    errorText: sitePathError
                        ? Localization.appLocalizations().cantBeEmpty
                        : null,
                    labelText: Localization.appLocalizations().websitePath,
                    hintText: Platform.isWindows
                        ? 'C:\\Documents\\Projects\\my-website'
                        : Platform.isMacOS
                            ? '/Users/user/Documents/my-website'
                            : 'home/user/Documents/my-website',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget svg({
    required String path,
    required double size,
    required String semanticsLabel,
  }) =>
      SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary, BlendMode.srcIn),
        semanticsLabel: semanticsLabel,
      );

  Widget recentSitePathTile({required String text, required int index}) {
    final recentPaths = Preferences.getRecentSitePaths();
    final ssg = recentPaths.entries.toList()[index].value;

    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(4.0, 4.0, 16.0, 4.0),
      onTap: () => open(sitePath: text, ssg: ssg),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      leading: DropdownButtonHideUnderline(
        child: DropdownButton<SSGTypes>(
          icon: Container(),
          value: ssg,
          items: SSGTypes.values
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Tooltip(
                        message: SSG.getSSGName(e),
                        child: svg(
                          path:
                              'assets/images/${SSG.getSSGName(e).toLowerCase()}.svg',
                          size: 32,
                          semanticsLabel: Localization.appLocalizations()
                              .currentSSG(SSG.getSSGName(e)),
                        ),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (option) async {
            if (option == null) return;
            final newRecentPaths = recentPaths;

            newRecentPaths[recentPaths.entries.toList()[index].key] = option;
            Preferences.setRecentSitePaths(newRecentPaths);
            setState(() {});
          },
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      trailing: IconButton(
        tooltip: Localization.appLocalizations().remove,
        splashRadius: 20,
        constraints: const BoxConstraints(minHeight: 48),
        onPressed: () {
          final entries = recentPaths.entries.toList();
          final newMap = <String, SSGTypes>{};

          entries.removeAt(index);
          for (final e in entries) {
            newMap.addEntries([e]);
          }
          Preferences.setRecentSitePaths(newMap);
          setState(() {});
        },
        icon: const Icon(Icons.close),
        padding: EdgeInsets.zero,
        iconSize: 20,
      ),
    );
  }

  Widget recentSitePaths() {
    final paths = Preferences.getRecentSitePaths();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restore),
              const SizedBox(width: 8.0),
              Text(Localization.appLocalizations().recentlyOpenedWebsites,
                  style: const TextStyle(fontSize: 20.0)),
            ],
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < paths.entries.length; i++)
                  recentSitePathTile(
                      text: paths.entries.toList()[i].key, index: i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.appLocalizations().openSite),
      ),
      body: Center(
        child: ListView(
          children: [
            recentSitePaths(),
            const Divider(),
            stepper(),
          ],
        ),
      ),
    );
  }
}
