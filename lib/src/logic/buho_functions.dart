import 'dart:io';

import 'package:buhocms/src/logic/files.dart';
import 'package:buhocms/src/pages/onboarding/theme_page.dart';
import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:buhocms/src/provider/editing/unsaved_text_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../pages/editing_page.dart';
import '../pages/onboarding/create_hugo_site.dart';
import '../pages/onboarding/open_hugo_site.dart';
import '../provider/editing/editing_provider.dart';
import '../provider/navigation/file_navigation_provider.dart';
import '../provider/navigation/navigation_provider.dart';
import '../utils/preferences.dart';
import '../utils/program_installed.dart';
import '../utils/terminal_command.dart';
import '../utils/unsaved_check.dart';
import '../widgets/file_navigation/context_menus/add_file.dart';
import '../widgets/file_navigation/context_menus/add_folder.dart';
import '../widgets/snackbar.dart';
import '../widgets/command_dialog.dart';

setGUIMode({
  required BuildContext context,
  required GlobalKey<EditingPageState> editingPageKey,
  required bool isGUIMode,
}) {
  checkUnsavedBeforeFunction(
    editingPageKey: editingPageKey,
    function: () {
      final editingProvider =
          Provider.of<EditingProvider>(context, listen: false);
      editingProvider.setIsGUIMode(isGUIMode);
      editingPageKey.currentState?.updateHugoWidgets();
    },
  );
}

refreshFiles({required BuildContext context}) {
  Provider.of<NavigationProvider>(context, listen: false).notifyAllListeners();
  showSnackbar(
    text: AppLocalizations.of(context)!.refreshedFileList,
    seconds: 2,
  );
}

openCurrentPathInFolder(
    {required String path, required bool keepPathTrailing}) {
  openInFolder(path: path, keepPathTrailing: keepPathTrailing);
}

addFile({
  required BuildContext context,
  required bool mounted,
  required GlobalKey<EditingPageState> editingPageKey,
}) {
  AddFile(context, mounted, editingPageKey,
          Provider.of<FileNavigationProvider>(context, listen: false))
      .newFile(
    path: Preferences.getCurrentPath(),
    editingPageKey: editingPageKey,
  );
}

addFolder({
  required BuildContext context,
  required bool mounted,
  required Function setStateCallback,
  required GlobalKey<EditingPageState> editingPageKey,
}) {
  AddFolder(context, mounted, editingPageKey).newFolder(
    path: Preferences.getCurrentPath(),
    editingPageKey: editingPageKey,
  );
}

save({
  required BuildContext context,
  required GlobalKey<EditingPageState> editingPageKey,
  bool checkUnsaved = true,
}) {
  if (editingPageKey.currentState == null) return;

  final unsavedTextProvider =
      Provider.of<UnsavedTextProvider>(context, listen: false);
  if (unsavedTextProvider.unsaved(
              globalKey: editingPageKey.currentState!.globalKey) ==
          true ||
      !checkUnsaved) {
    showSnackbar(
      text: AppLocalizations.of(context)!.fileSavedSuccessfully,
      seconds: 2,
    );
    editingPageKey.currentState?.saveFileAndFrontmatter();
  } else {
    showSnackbar(
      text: AppLocalizations.of(context)!.nothingToSave,
      seconds: 1,
    );
  }
}

revert({
  required BuildContext context,
  required GlobalKey<EditingPageState> editingPageKey,
  required bool mounted,
}) async {
  if (editingPageKey.currentState == null) return;

  final unsavedTextProvider =
      Provider.of<UnsavedTextProvider>(context, listen: false);
  if (unsavedTextProvider.unsaved(
      globalKey: editingPageKey.currentState!.globalKey)) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.revertChanges),
        content: Text(AppLocalizations.of(context)!.revertChanges_Description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              showSnackbar(
                text: AppLocalizations.of(context)!.fileRevertedSuccessfully,
                seconds: 2,
              );
              await editingPageKey.currentState?.revertFileAndFrontmatter();
              if (mounted) Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.yes),
          ),
        ],
      ),
    );
  } else {
    showSnackbar(
      text: AppLocalizations.of(context)!.nothingToRevert,
      seconds: 1,
    );
  }
}

void openHugoSite({required BuildContext context, Function? setState}) {
  Navigator.push(context,
          MaterialPageRoute(builder: (context) => const OpenHugoSite()))
      .then((value) => setState?.call());
}

void createHugoSite({required BuildContext context, Function? setState}) {
  Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CreateHugoSite()))
      .then((value) => setState?.call());
}

void openHugoThemes({required BuildContext context, Function? setState}) {
  Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ThemePage()))
      .then((value) => setState?.call());
}

void startHugoServer({required BuildContext context}) {
  var flags = '';
  final hugoServerController = TextEditingController();

  start() {
    final commandToRun = 'hugo server $flags';
    final shellProvider = Provider.of<ShellProvider>(context, listen: false);
    checkProgramInstalled(
      context: context,
      command: commandToRun,
      executable: 'hugo',
    );

    showSnackbar(
      text: shellProvider.shellActive == true
          ? AppLocalizations.of(context)!.alreadyStartedAHugoServer
          : AppLocalizations.of(context)!.startedHugoServer,
      seconds: 4,
    );

    runTerminalCommandWithShell(
      context: context,
      shell: shellProvider.shell,
      successFunction: () => shellProvider.setShellActive(true),
      command: commandToRun,
    );

    Navigator.pop(context);
  }

  showDialog(
    context: context,
    builder: (context) {
      return LayoutBuilder(builder: (context, constraints) {
        return StatefulBuilder(builder: (context, setState) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
            children: [
              Column(
                children: [
                  const Icon(Icons.miscellaneous_services, size: 64.0),
                  const SizedBox(height: 16.0),
                  Text(
                    AppLocalizations.of(context)!.startHugoServer,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              ExpansionTile(
                leading: const Icon(Icons.terminal),
                title: Text(AppLocalizations.of(context)!.terminal),
                expandedAlignment: Alignment.topLeft,
                children: [
                  CustomTextField(
                    readOnly: true,
                    controller: hugoServerController,
                    leading: Text(AppLocalizations.of(context)!.command),
                    initialText: 'hugo server',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    leading: Text(AppLocalizations.of(context)!.flags),
                    onChanged: (value) {
                      setState(() {
                        flags = value;
                      });
                    },
                    helperText: '"--theme hugo-PaperMod"',
                  ),
                ],
              ),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () => start(),
                    child: Text(AppLocalizations.of(context)!.yes),
                  ),
                ],
              ),
            ],
          );
        });
      });
    },
  );
}

void stopHugoServer({required BuildContext context, bool snackbar = true}) {
  final shellProvider = Provider.of<ShellProvider>(context, listen: false);

  if (snackbar) {
    showSnackbar(
      text: shellProvider.shellActive == true
          ? AppLocalizations.of(context)!.stoppedHugoServer
          : AppLocalizations.of(context)!.noHugoServerRunning,
      seconds: 4,
    );
  }

  shellProvider.kill();
}

void buildHugoSite({required BuildContext context}) async {
  checkProgramInstalled(
    context: context,
    command: 'hugo',
    executable: 'hugo',
  );

  showSnackbar(
    text: AppLocalizations.of(context)!.builtHugoSite,
    seconds: 4,
  );

  const commandToRun = 'hugo';
  await runTerminalCommand(
    context: context,
    workingDirectory: Preferences.getSitePath(),
    command: commandToRun,
  );
}

void openHugoPublicFolder({required BuildContext context}) {
  openInFolder(
    path:
        '${Preferences.getSitePath()}${Platform.pathSeparator}public${Platform.pathSeparator}index.html',
    keepPathTrailing: false,
  );
}

void exit({
  required BuildContext context,
  required GlobalKey<EditingPageState> editingPageKey,
  required Function close,
  Function(bool)? setClosingWindow,
}) async {
  final shellProvider = Provider.of<ShellProvider>(context, listen: false);
  final unsavedTextProvider =
      Provider.of<UnsavedTextProvider>(context, listen: false);
  var unsaved = editingPageKey.currentState != null
      ? unsavedTextProvider.unsaved(
          globalKey: editingPageKey.currentState!.globalKey)
      : false;

  if (unsaved) {
    setClosingWindow?.call(true);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.quitWithUnsaved),
          content:
              Text(AppLocalizations.of(context)!.quitWithUnsaved_Description),
          actionsOverflowButtonSpacing: 8.0,
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setClosingWindow?.call(false);
                },
                child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
              onPressed: () async {
                await editingPageKey.currentState?.revertFileAndFrontmatter();
                shellProvider.kill();

                close();
              },
              child: Text(AppLocalizations.of(context)!.revertAndQuit),
            ),
            ElevatedButton(
              onPressed: () async {
                await editingPageKey.currentState?.saveFileAndFrontmatter();
                shellProvider.kill();

                close();
              },
              child: Text(AppLocalizations.of(context)!.saveAndQuit),
            ),
          ],
        );
      },
    );
    setClosingWindow?.call(false);
  } else {
    shellProvider.kill();
    close();
  }
}

void openHomepage() async {
  final url = Uri(scheme: 'https', path: 'github.com/iakmds/buhocms');
  if (await canLaunchUrl(url) || Platform.isLinux) {
    await launchUrl(url);
  }
}

void reportIssue() async {
  final url = Uri(scheme: 'https', path: 'github.com/iakmds/buhocms/issues');
  if (await canLaunchUrl(url) || Platform.isLinux) {
    await launchUrl(url);
  }
}

void about({required BuildContext context}) {
  showAboutDialog(
    context: context,
    applicationName: 'BuhoCMS',
    applicationVersion: AppLocalizations.of(context)!.version(
      '0.1.0 Alpha',
    ), //TODO update version number
    applicationIcon: const Image(
      image: AssetImage('assets/images/icon.png'),
      width: 64,
      height: 64,
    ),
    applicationLegalese: 'GNU Public License v3',
    children: [
      SizedBox(
        width: 500,
        child: SelectableText(AppLocalizations.of(context)!.license),
      ),
    ],
  );
}
