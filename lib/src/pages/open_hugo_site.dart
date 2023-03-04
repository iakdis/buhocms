import 'dart:io';

import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../provider/app/shell_provider.dart';
import '../provider/navigation/navigation_provider.dart';
import '../utils/preferences.dart';

class OpenHugoSite extends StatefulWidget {
  const OpenHugoSite({super.key});

  @override
  State<OpenHugoSite> createState() => _OpenHugoSiteState();
}

class _OpenHugoSiteState extends State<OpenHugoSite> {
  int currentStep = 0;
  bool canContinue = false;

  String sitePath = Preferences.getSitePath() ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.openSite),
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
            } else {
              stopHugoServer(context: context, snackbar: false);

              Preferences.clearPreferences();
              Preferences.setOnBoardingComplete(true);

              Preferences.setSitePath(sitePath);
              Preferences.setCurrentPath(
                  '${Preferences.getSitePath()}${Platform.pathSeparator}content');

              Provider.of<ShellProvider>(context, listen: false).updateShell();

              if (mounted) {
                Navigator.of(context).pop();
                Provider.of<NavigationProvider>(context, listen: false)
                    .notifyAllListeners();
              }
            }
          },
          onStepCancel: () {
            if (currentStep > 0) {
              setState(() {
                currentStep--;
              });
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
                    child: Text(details.stepIndex < 2
                        ? AppLocalizations.of(context)!.continue2
                        : AppLocalizations.of(context)!.open.toUpperCase()),
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
              title:
                  Text(AppLocalizations.of(context)!.checkHugoFolderStructure),
              content: Column(
                children: [
                  SizedBox(
                    width: 700,
                    child: SelectableText(
                      AppLocalizations.of(context)!
                          .checkHugoFolderStructure_Description,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Tooltip(
                    message:
                        'https://gohugo.io/getting-started/directory-structure/',
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri(
                            scheme: 'https',
                            path:
                                'gohugo.io/getting-started/directory-structure/');
                        if (await canLaunchUrl(url) || Platform.isLinux) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: Text(
                          AppLocalizations.of(context)!.openHugoDocumentation),
                    ),
                  ),
                ],
              ),
            ),
            Step(
              isActive: currentStep >= 1,
              title: Text(AppLocalizations.of(context)!.selectSiteFolder),
              content: Column(
                children: [
                  ElevatedButton(
                      onPressed: savePath,
                      child: Text(AppLocalizations.of(context)!.choosePath)),
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
                            ? AppLocalizations.of(context)!.cantBeEmpty
                            : null,
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.savePath,
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
            Step(
              isActive: currentStep >= 2,
              title: Text(AppLocalizations.of(context)!.open),
              content: Column(
                children: [
                  SelectableText.rich(TextSpan(
                      text: AppLocalizations.of(context)!.openHugoSite,
                      style: const TextStyle(fontSize: 20),
                      children: <TextSpan>[
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
