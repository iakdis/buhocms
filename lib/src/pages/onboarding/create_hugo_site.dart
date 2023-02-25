import 'dart:io';

import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../logic/buho_functions.dart';
import '../../provider/navigation/navigation_provider.dart';
import '../../ssg/hugo.dart';
import '../../utils/preferences.dart';
import '../../widgets/snackbar.dart';

class CreateHugoSite extends StatefulWidget {
  const CreateHugoSite({super.key});

  @override
  State<CreateHugoSite> createState() => _CreateHugoSiteState();
}

class _CreateHugoSiteState extends State<CreateHugoSite> {
  int currentStep = 0;
  bool canContinue = false;

  bool? hugoInstalled;
  String hugoInstalledText = '';

  String sitePath = Preferences.getSitePath() ?? '';
  bool sitePathError = false;
  TextEditingController textController = TextEditingController();
  String siteName = '';
  bool siteNameError = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createSite),
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
            if (currentStep == 0) {
              setState(() => currentStep++);
            } else if (currentStep == 1) {
              if (sitePath.isEmpty) {
                setState(() => sitePathError = true);
                return;
              }
              if (!Directory(sitePath).existsSync()) {
                showSnackbar(
                  text: AppLocalizations.of(context)!
                      .error_DirectoryDoesNotExist('"$sitePath"'),
                  seconds: 4,
                );
                return;
              }
              setState(() => currentStep++);
            } else if (currentStep == 2) {
              final path = '$sitePath${Platform.pathSeparator}$siteName';
              if (siteName.isEmpty) {
                setState(() => siteNameError = true);
                return;
              }
              if (Directory(path).existsSync()) {
                showSnackbar(
                  text: AppLocalizations.of(context)!
                      .error_DirectoryAlreadyExists('"$path"'),
                  seconds: 4,
                );
                return;
              }
              setState(() => currentStep++);
            } else {
              print('CREATE');
              checkHugoInstalled(
                context: context,
                command: 'hugo new site $siteName',
              );
              var shell = Shell(workingDirectory: sitePath);
              await shell.run('''

              echo Start!

              # Create Hugo site
              hugo new site $siteName

          ''');
              shell.kill();

              Preferences.clearPreferences();
              Preferences.setOnBoardingComplete(true);

              Preferences.setSitePath(
                  '$sitePath${Platform.pathSeparator}$siteName');
              Preferences.setCurrentPath(
                  '${Preferences.getSitePath()}${Platform.pathSeparator}content');

              shellProvider.updateShell();

              if (mounted) {
                stopHugoServer(context: context, snackbar: false);

                Navigator.of(context).pop();
                Provider.of<NavigationProvider>(context, listen: false)
                    .notifyAllListeners();
              }
            }
          },
          onStepCancel: () {
            if (currentStep > 0) {
              setState(() => currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            canContinue = hugoInstalled == true &&
                (details.stepIndex == 1 ? !sitePathError : true) &&
                (details.stepIndex == 2 ? !siteNameError : true);

            return Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: canContinue ? details.onStepContinue : null,
                    child: Text(details.stepIndex < 3
                        ? AppLocalizations.of(context)!.continue2
                        : AppLocalizations.of(context)!.create.toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed:
                        details.stepIndex > 0 ? details.onStepCancel : null,
                    child: Text(AppLocalizations.of(context)!.back),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              isActive: currentStep >= 0,
              title: Text(AppLocalizations.of(context)!.checkHugoInstalled),
              content: Column(
                children: [
                  Icon(
                    hugoInstalled == null
                        ? Icons.question_mark
                        : hugoInstalled == true
                            ? Icons.check
                            : Icons.close,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      var hugoExectutable = await which('hugo');
                      if (hugoExectutable == null) {
                        hugoInstalled = false;
                        if (mounted) {
                          hugoInstalledText = AppLocalizations.of(context)!
                              .hugoExectutableNotFound;
                        }
                        setState(() {});
                      } else {
                        hugoInstalled = true;
                        if (mounted) {
                          hugoInstalledText = AppLocalizations.of(context)!
                              .hugoExectutableFoundIn(hugoExectutable);
                        }
                        setState(() {});
                      }
                    },
                    child:
                        Text(AppLocalizations.of(context)!.checkHugoInstalled),
                  ),
                  const SizedBox(height: 16),
                  Text(hugoInstalledText),
                ],
              ),
            ),
            Step(
              isActive: currentStep >= 1,
              title: Text(AppLocalizations.of(context)!.createLocation),
              content: Column(
                children: [
                  ElevatedButton(
                      onPressed: savePath,
                      child: Text(AppLocalizations.of(context)!.choosePath)),
                  const SizedBox(height: 24.0),
                  Text(AppLocalizations.of(context)!
                      .hugoSiteWillBeCreatedInFolder),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      onChanged: (value) {
                        if (textController.text.isNotEmpty &&
                            textController
                                    .text[textController.text.length - 1] ==
                                Platform.pathSeparator) {
                          textController.text = textController.text
                              .substring(0, textController.text.length - 1);
                          textController.selection = TextSelection(
                              baseOffset: textController.text.length,
                              extentOffset: textController.text.length);
                        }
                        sitePath = textController.text;
                        sitePathError = false;
                        setState(() {});
                      },
                      controller: textController,
                      style: TextStyle(color: Colors.grey[600], fontSize: 17.0),
                      decoration: InputDecoration(
                        errorText: sitePathError
                            ? AppLocalizations.of(context)!.cantBeEmpty
                            : null,
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.savePath,
                        isDense: true,
                        hintText: Platform.isWindows
                            ? 'C:\\Documents\\HugoWebsites'
                            : Platform.isMacOS
                                ? '/Users/user/Documents/HugoWebsites'
                                : 'home/user/Documents/HugoWebsites',
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
              isActive: currentStep >= 3,
              title: Text(AppLocalizations.of(context)!.siteName),
              content: Column(
                children: [
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      onChanged: (value) {
                        siteName = value;
                        siteNameError = false;
                        setState(() {});
                      },
                      style: TextStyle(color: Colors.grey[600], fontSize: 17.0),
                      decoration: InputDecoration(
                        errorText: siteNameError
                            ? AppLocalizations.of(context)!.cantBeEmpty
                            : null,
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.siteName,
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
            Step(
              isActive: currentStep >= 4,
              title: Text(AppLocalizations.of(context)!.finish),
              content: Column(
                children: [
                  SelectableText.rich(TextSpan(
                      text: AppLocalizations.of(context)!.createHugoSiteNamed,
                      style: const TextStyle(fontSize: 20),
                      children: <TextSpan>[
                        TextSpan(
                          text: '"$siteName"\n\n',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                            text: AppLocalizations.of(context)!.insideFolder),
                        TextSpan(
                          text: '"$sitePath"',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
