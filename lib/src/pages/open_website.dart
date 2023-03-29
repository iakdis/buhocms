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
  SSGTypes ssg = SSGTypes.values.byName(Preferences.getSSG());
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
    await Preferences.setCurrentPath(
        '${Preferences.getSitePath()}${Platform.pathSeparator}content');

    setState(() {
      sitePathError = false;
      sitePath = Preferences.getSitePath() ?? '';
      textController.text = sitePath;
      textController.selection = TextSelection(
          baseOffset: textController.text.length,
          extentOffset: textController.text.length);
    });
  }

  void open({required String sitePath}) {
    stopSSGServer(context: context, ssg: 'Hugo', snackbar: false);

    Preferences.clearPreferencesSite();
    Preferences.setOnBoardingComplete(true);

    Preferences.setSitePath(sitePath);
    Preferences.setCurrentPath(
        '${Preferences.getSitePath()}${Platform.pathSeparator}content');
    final recentPaths = Preferences.getRecentSitePaths();

    if (recentPaths.contains(sitePath)) {
      for (var i = 0; i < recentPaths.length; i++) {
        if (recentPaths[i] == sitePath) {
          recentPaths.removeAt(i);
        }
      }
    }
    Preferences.setRecentSitePaths(recentPaths..insert(0, sitePath));

    context.read<SSGProvider>().setSSG(ssg.name);

    Provider.of<ShellProvider>(context, listen: false).updateShell();

    Navigator.of(context).pop();
    Provider.of<NavigationProvider>(context, listen: false)
        .notifyAllListeners();
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
          open(sitePath: sitePath);
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
                  if (ssg != SSGTypes.none)
                    SvgPicture.asset(
                      'assets/images/${SSG.getSSGName(ssg).toLowerCase()}.svg',
                      width: 64,
                      height: 64,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                      semanticsLabel: Localization.appLocalizations()
                          .logo(SSG.getSSGName(ssg)),
                    ),
                  const SizedBox(height: 32),
                  DropdownButton<SSGTypes>(
                    value: ssg,
                    items: SSGTypes.values
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(SSG.getSSGName(e))))
                        .toList(),
                    onChanged: (option) async {
                      if (option == null) return;
                      ssg = option;
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
                    border: const OutlineInputBorder(),
                    labelText: Localization.appLocalizations().websitePath,
                    isDense: true,
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

  Widget recentSitePathTile({required String text, required int index}) {
    return Material(
      child: InkWell(
        onTap: () => open(sitePath: text),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(text, style: const TextStyle(fontSize: 16))),
              IconButton(
                splashRadius: 20,
                constraints: const BoxConstraints(minHeight: 48),
                onPressed: () {
                  Preferences.setRecentSitePaths(
                      Preferences.getRecentSitePaths()..removeAt(index));
                  setState(() {});
                },
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                iconSize: 20,
              ),
            ],
          ),
        ),
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
                for (var i = 0; i < paths.length; i++)
                  recentSitePathTile(text: paths[i], index: i),
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
