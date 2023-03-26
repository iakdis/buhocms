import 'dart:io';

import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:buhocms/src/ssg/ssg.dart';
import 'package:buhocms/src/utils/terminal_command.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/l10n.dart';
import '../logic/buho_functions.dart';
import '../provider/navigation/navigation_provider.dart';
import '../utils/preferences.dart';
import '../utils/program_installed.dart';
import '../widgets/command_dialog.dart';
import '../widgets/snackbar.dart';

class CreateWebsite extends StatefulWidget {
  const CreateWebsite({super.key});

  @override
  State<CreateWebsite> createState() => _CreateWebsiteState();
}

class _CreateWebsiteState extends State<CreateWebsite> {
  int currentStep = 0;
  bool canContinue = false;

  bool? ssgInstalled;
  String ssgInstalledText = '';

  String sitePath = Preferences.getSitePath() ?? '';
  SSGTypes ssg = SSGTypes.values.byName(Preferences.getSSG());
  String path = '';
  bool sitePathError = false;
  TextEditingController textController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String siteName = '';
  bool siteNameError = false;
  bool directoryAlreadyExists = false;

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
    nameController.dispose();
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

  void checkExecutableInstalled() {
    checkProgramInstalled(
      context: context,
      executable: SSG.getSSGExecutable(ssg),
      notFound: () {
        ssgInstalled = false;
        if (mounted) {
          ssgInstalledText = Localization.appLocalizations()
              .executableNotFound(SSG.getSSGName(ssg));
        }
        setState(() {});
      },
      found: (finalExecutable) {
        ssgInstalled = true;
        if (mounted) {
          ssgInstalledText = Localization.appLocalizations()
              .executableFoundIn(SSG.getSSGName(ssg), finalExecutable);
        }
        setState(() {});
      },
      showErrorSnackbar: false,
    );
  }

  void onChangedText({
    required Function setState,
    required String value,
  }) {
    siteName = value;
    siteNameError = false;

    path = '$sitePath${Platform.pathSeparator}$siteName';

    directoryAlreadyExists = Directory(path).existsSync();
    if (siteName.isEmpty) siteNameError = true;

    setState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.appLocalizations().createSite),
      ),
      body: Center(
        child: Stepper(
          currentStep: currentStep,
          /*onStepTapped: canContinue
              ? (index) {
                  setState(() {
                    currentStep = index;
                  });
                }
              : null,*/
          onStepContinue: () async {
            switch (currentStep) {
              case 0:
                setState(() => currentStep++);
                break;
              case 1:
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
                setState(() => currentStep++);
                break;
              case 2:
                path = '$sitePath${Platform.pathSeparator}$siteName';
                var flags = '';

                create() async {
                  path = '$sitePath${Platform.pathSeparator}$siteName';

                  final shellProvider =
                      Provider.of<ShellProvider>(context, listen: false);
                  final commandToRun = 'hugo new site $siteName $flags';

                  checkProgramInstalled(
                    context: context,
                    command: commandToRun,
                    executable: 'hugo',
                  );
                  await runTerminalCommand(
                    context: context,
                    workingDirectory: sitePath,
                    command: commandToRun,
                  );

                  Preferences.clearPreferencesSite();
                  Preferences.setOnBoardingComplete(true);

                  final finalSitePath =
                      '$sitePath${Platform.pathSeparator}$siteName';

                  Preferences.setSitePath(finalSitePath);
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
                  Preferences.setRecentSitePaths(
                      recentPaths..insert(0, finalSitePath));

                  Preferences.setSSG(ssg.name);

                  shellProvider.updateShell();

                  if (mounted) {
                    stopSSGServer(
                        context: context, ssg: 'Hugo', snackbar: false);

                    Navigator.pop(context);
                    Navigator.pop(context);
                    Provider.of<NavigationProvider>(context, listen: false)
                        .notifyAllListeners();
                  }
                }

                await showDialog(
                  context: context,
                  builder: (context) {
                    directoryAlreadyExists = Directory(path).existsSync();

                    return StatefulBuilder(builder: (context, setState) {
                      return CommandDialog(
                        title: SelectableText.rich(TextSpan(
                            text: Localization.appLocalizations()
                                .createWebsiteNamed(SSG.getSSGName(ssg)),
                            style: const TextStyle(fontSize: 20),
                            children: <TextSpan>[
                              TextSpan(
                                text: '$siteName\n\n',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                  text: Localization.appLocalizations()
                                      .insideFolder),
                              TextSpan(
                                text: sitePath,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ])),
                        icon: Icons.create_new_folder,
                        expansionIcon: Icons.terminal,
                        expansionTitle:
                            Localization.appLocalizations().terminal,
                        yes: () => create(),
                        dialogChildren: const [],
                        expansionChildren: [
                          CustomTextField(
                            leading:
                                Text(Localization.appLocalizations().command),
                            controller: nameController,
                            onChanged: (value) => onChangedText(
                              setState: () => setState(() {}),
                              value: value,
                            ),
                            prefixText: 'hugo new site ',
                            helperText: '"hugo new site my-website"',
                            errorText: siteNameError
                                ? Localization.appLocalizations().cantBeEmpty
                                : directoryAlreadyExists
                                    ? Localization.appLocalizations()
                                        .error_DirectoryAlreadyExists('"$path"')
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            leading:
                                Text(Localization.appLocalizations().flags),
                            onChanged: (value) {
                              setState(() => flags = value);
                            },
                            helperText: '"--force"',
                          ),
                        ],
                      );
                    });
                  },
                );
                setState(() {});
                break;
              default:
            }
          },
          onStepCancel: () {
            if (currentStep > 0) {
              setState(() => currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            canContinue = ssgInstalled == true &&
                (details.stepIndex == 1 ? !sitePathError : true) &&
                (details.stepIndex == 2
                    ? !siteNameError &&
                        siteName.isNotEmpty &&
                        !directoryAlreadyExists
                    : true);

            return Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: canContinue ? details.onStepContinue : null,
                    child: Text(details.stepIndex < 3
                        ? Localization.appLocalizations().continue2
                        : Localization.appLocalizations().create.toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed:
                        details.stepIndex > 0 ? details.onStepCancel : null,
                    child: Text(Localization.appLocalizations().back),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              isActive: currentStep >= 0,
              title: Text(Localization.appLocalizations().checkExecutableFound),
              content: Wrap(
                spacing: 128.0,
                runSpacing: 32.0,
                alignment: WrapAlignment.center,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.web_stories,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
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
                          ssgInstalled = false;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  if (ssg != SSGTypes.none)
                    Column(
                      children: [
                        Icon(
                          ssgInstalled == null
                              ? Icons.question_mark
                              : ssgInstalled == true
                                  ? Icons.check
                                  : Icons.close,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => checkExecutableInstalled(),
                          child: Text(Localization.appLocalizations()
                              .checkSSGInstalled(SSG.getSSGName(ssg))),
                        ),
                        const SizedBox(height: 16),
                        Text(ssgInstalledText),
                      ],
                    ),
                ],
              ),
            ),
            Step(
              isActive: currentStep >= 1,
              title: Text(Localization.appLocalizations().createLocation),
              content: Column(
                children: [
                  ElevatedButton(
                      onPressed: savePath,
                      child: Text(Localization.appLocalizations().choosePath)),
                  const SizedBox(height: 24.0),
                  Text(Localization.appLocalizations()
                      .websiteWillBeCreatedInFolder(SSG.getSSGName(ssg))),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      onChanged: (value) {
                        var end = textController.text.length;
                        if (textController.text.isNotEmpty &&
                            textController
                                    .text[textController.text.length - 1] ==
                                Platform.pathSeparator) {
                          end = textController.text.length - 1;
                        }
                        sitePath =
                            sitePath = textController.text.substring(0, end);
                        sitePathError = false;
                        setState(() {});
                      },
                      controller: textController,
                      style: TextStyle(color: Colors.grey[600], fontSize: 17.0),
                      decoration: InputDecoration(
                        errorText: sitePathError
                            ? Localization.appLocalizations().cantBeEmpty
                            : null,
                        errorMaxLines: 5,
                        border: const OutlineInputBorder(),
                        labelText: Localization.appLocalizations().websitePath,
                        isDense: true,
                        hintText: Platform.isWindows
                            ? 'C:\\Documents\\Websites'
                            : Platform.isMacOS
                                ? '/Users/user/Documents/Websites'
                                : 'home/user/Documents/Websites',
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
            Step(
              isActive: currentStep >= 2,
              title: Text(Localization.appLocalizations().siteName),
              content: Column(
                children: [
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: nameController,
                      onChanged: (value) => onChangedText(
                        setState: () => setState(() {}),
                        value: value,
                      ),
                      style: TextStyle(color: Colors.grey[600], fontSize: 17.0),
                      decoration: InputDecoration(
                        errorText: siteNameError
                            ? Localization.appLocalizations().cantBeEmpty
                            : directoryAlreadyExists
                                ? Localization.appLocalizations()
                                    .error_DirectoryAlreadyExists(
                                        '"$sitePath${Platform.pathSeparator}$siteName"')
                                : null,
                        errorMaxLines: 5,
                        border: const OutlineInputBorder(),
                        labelText: Localization.appLocalizations().siteName,
                        isDense: true,
                        hintText: 'my-website',
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
        ),
      ),
    );
  }
}
