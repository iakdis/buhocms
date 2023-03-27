import 'dart:io';

import 'package:buhocms/src/logic/files.dart';
import 'package:buhocms/src/pages/theme_page.dart';
import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:buhocms/src/provider/editing/unsaved_text_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../i18n/l10n.dart';
import '../pages/create_website.dart';
import '../pages/open_website.dart';
import '../provider/editing/editing_provider.dart';
import '../provider/navigation/file_navigation_provider.dart';
import '../provider/navigation/navigation_provider.dart';
import '../ssg/ssg.dart';
import '../utils/preferences.dart';
import '../utils/program_installed.dart';
import '../utils/terminal_command.dart';
import '../utils/unsaved_check.dart';
import '../widgets/file_navigation/context_menus/add_file.dart';
import '../widgets/file_navigation/context_menus/add_folder.dart';
import '../widgets/snackbar.dart';
import '../widgets/command_dialog.dart';

void setGUIMode({
  required BuildContext context,
  required bool isGUIMode,
}) {
  checkUnsavedBeforeFunction(
    context: context,
    function: () {
      final editingProvider =
          Provider.of<EditingProvider>(context, listen: false);
      editingProvider.setIsGUIMode(isGUIMode);
      editingProvider.editingPageKey.currentState?.updateFrontmatterWidgets();
    },
  );
}

void refreshFiles({required BuildContext context}) {
  Provider.of<NavigationProvider>(context, listen: false).notifyAllListeners();
  showSnackbar(
    text: Localization.appLocalizations().refreshedFileList,
    seconds: 2,
  );
}

void openCurrentPathInFolder(
    {required String path, required bool keepPathTrailing}) {
  openInFolder(path: path, keepPathTrailing: keepPathTrailing);
}

void addFile({
  required BuildContext context,
  required bool mounted,
}) {
  final fileNavigationProvider =
      Provider.of<FileNavigationProvider>(context, listen: false);
  AddFile(
    context: context,
    mounted: mounted,
    setFileNavigationIndex: fileNavigationProvider.setFileNavigationIndex,
    setInitialTexts: fileNavigationProvider.setInitialTexts,
    fileNavigationIndex: fileNavigationProvider.fileNavigationIndex,
  ).newFile(
    path: Preferences.getCurrentPath(),
  );
}

void addFolder({
  required BuildContext context,
  required bool mounted,
  required Function setStateCallback,
}) {
  AddFolder(context, mounted).newFolder(
    path: Preferences.getCurrentPath(),
  );
}

void save({
  required BuildContext context,
  bool checkUnsaved = true,
}) {
  final editingPageKey = context.read<EditingProvider>();
  if (editingPageKey.editingPageKey.currentState == null) return;

  final unsavedTextProvider =
      Provider.of<UnsavedTextProvider>(context, listen: false);
  if (unsavedTextProvider.unsaved(
              frontmatterKeys: editingPageKey.frontmatterKeys) ==
          true ||
      !checkUnsaved) {
    showSnackbar(
      text: Localization.appLocalizations().fileSavedSuccessfully,
      seconds: 2,
    );
    saveFileAndFrontmatter(context: context);
  } else {
    showSnackbar(
      text: Localization.appLocalizations().nothingToSave,
      seconds: 1,
    );
  }
}

Future<void> saveFileAndFrontmatter({required BuildContext context}) async {
  final unsavedTextProvider = context.read<UnsavedTextProvider>();
  final fileNavigationProvider = context.read<FileNavigationProvider>();
  final editingProvider = context.read<EditingProvider>();
  for (var i = 0; i < editingProvider.frontmatterKeys.length; i++) {
    editingProvider.frontmatterKeys[i].currentState?.save();
  }
  await saveFile(context);

  unsavedTextProvider.setSavedText(fileNavigationProvider.markdownTextContent);
  unsavedTextProvider
      .setSavedTextFrontmatter(fileNavigationProvider.frontMatterText);

  editingProvider.editingPageKey.currentState?.updateFrontmatterWidgets();
}

void revert({
  required BuildContext context,
  required bool mounted,
}) async {
  final editingPageKey = context.read<EditingProvider>();
  if (editingPageKey.editingPageKey.currentState == null) return;

  final unsavedTextProvider =
      Provider.of<UnsavedTextProvider>(context, listen: false);
  if (unsavedTextProvider.unsaved(
      frontmatterKeys: editingPageKey.frontmatterKeys)) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localization.appLocalizations().revertChanges),
        content: SizedBox(
            width: 512.0,
            child: SelectableText(
                Localization.appLocalizations().revertChanges_Description)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localization.appLocalizations().cancel),
          ),
          TextButton(
            onPressed: () async {
              showSnackbar(
                text: Localization.appLocalizations().fileRevertedSuccessfully,
                seconds: 2,
              );
              await revertFileAndFrontmatter(context: context);
              if (mounted) Navigator.pop(context);
            },
            child: Text(Localization.appLocalizations().yes),
          ),
        ],
      ),
    );
  } else {
    showSnackbar(
      text: Localization.appLocalizations().nothingToRevert,
      seconds: 1,
    );
  }
}

Future<void> revertFileAndFrontmatter({required BuildContext context}) async {
  final unsavedTextProvider = context.read<UnsavedTextProvider>();
  final fileNavigationProvider = context.read<FileNavigationProvider>();
  final editingProvider = context.read<EditingProvider>();

  for (var i = 0; i < editingProvider.frontmatterKeys.length; i++) {
    editingProvider.frontmatterKeys[i].currentState?.restore();
  }

  if (editingProvider.isGUIMode) {
    fileNavigationProvider
        .setMarkdownTextContent(unsavedTextProvider.savedText);
    fileNavigationProvider
        .setFrontMatterText(unsavedTextProvider.savedTextFrontmatter);
  } else {
    var frontMatterText = unsavedTextProvider.savedText
        .substring(0, unsavedTextProvider.savedText.indexOf('---', 1) + 3)
        .trim();
    var markdownTextContent = unsavedTextProvider.savedText;
    fileNavigationProvider.setFrontMatterText(frontMatterText);
    fileNavigationProvider.setMarkdownTextContent(markdownTextContent);
  }

  fileNavigationProvider.controller.text =
      fileNavigationProvider.markdownTextContent;
  unsavedTextProvider.setSavedText(fileNavigationProvider.markdownTextContent);
  fileNavigationProvider.controllerFrontmatter.text =
      fileNavigationProvider.frontMatterText;
  unsavedTextProvider
      .setSavedTextFrontmatter(fileNavigationProvider.frontMatterText);
}

void openHugoSite({required BuildContext context, Function? setState}) {
  Navigator.push(
          context, MaterialPageRoute(builder: (context) => const OpenWebsite()))
      .then((value) => setState?.call());
}

void createHugoSite({required BuildContext context, Function? setState}) {
  Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CreateWebsite()))
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
      ssg: SSGTypes.values.byName(Preferences.getSSG()),
    );

    shellProvider.updateController();

    runTerminalCommandServer(
      context: context,
      shell: shellProvider.shell(),
      controller: shellProvider.controller,
      successFunction: () => shellProvider.setShellActive(true),
      errorFunction: () => shellProvider.setShellActive(false),
      command: commandToRun,
      snackbarFunction: () => showSnackbar(
        text: shellProvider.shellActive == true
            ? Localization.appLocalizations().alreadyStartedAHugoServer
            : Localization.appLocalizations().startedHugoServer,
        seconds: 4,
      ),
    );

    Navigator.pop(context);
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return CommandDialog(
          title: Text(
            Localization.appLocalizations().startHugoServer,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          icon: Icons.miscellaneous_services,
          expansionIcon: Icons.terminal,
          expansionTitle: Localization.appLocalizations().terminal,
          yes: () => start(),
          dialogChildren: const [],
          expansionChildren: [
            CustomTextField(
              readOnly: true,
              controller: hugoServerController,
              leading: Text(Localization.appLocalizations().command),
              initialText: 'hugo server',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              leading: Text(Localization.appLocalizations().flags),
              onChanged: (value) {
                setState(() {
                  flags = value;
                });
              },
              helperText: '"--theme hugo-PaperMod"',
            ),
          ],
        );
      });
    },
  );
}

void stopSSGServer({
  required BuildContext context,
  required String ssg,
  bool snackbar = true,
}) {
  final shellProvider = context.read<ShellProvider>();

  if (snackbar) {
    showSnackbar(
      text: shellProvider.shellActive == true
          ? Localization.appLocalizations().stoppedSSGServer(ssg)
          : Localization.appLocalizations().noSSGServerRunning(ssg),
      seconds: 4,
    );
  }

  shellProvider.kill();
}

void buildHugoSite({required BuildContext context}) async {
  var flags = '';
  final hugoController = TextEditingController();

  build() async {
    final commandToRun = 'hugo $flags';

    checkProgramInstalled(
      context: context,
      command: commandToRun,
      executable: 'hugo',
      ssg: SSGTypes.values.byName(Preferences.getSSG()),
    );

    runTerminalCommand(
      context: context,
      workingDirectory: Preferences.getSitePath(),
      command: commandToRun,
      successFunction: () => showSnackbar(
        text: Localization.appLocalizations().builtHugoSite,
        seconds: 4,
      ),
    );

    Navigator.pop(context);
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return CommandDialog(
          title: Text(
            Localization.appLocalizations().buildHugoSite,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          icon: Icons.web,
          expansionIcon: Icons.terminal,
          expansionTitle: Localization.appLocalizations().terminal,
          yes: () => build(),
          dialogChildren: const [],
          expansionChildren: [
            CustomTextField(
              readOnly: true,
              controller: hugoController,
              leading: Text(Localization.appLocalizations().command),
              initialText: 'hugo',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              leading: Text(Localization.appLocalizations().flags),
              onChanged: (value) {
                setState(() {
                  flags = value;
                });
              },
              helperText: '"--buildDrafts"',
            ),
          ],
        );
      });
    },
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
  required Function close,
  Function(bool)? setClosingWindow,
}) async {
  final shellProvider = Provider.of<ShellProvider>(context, listen: false);
  final unsavedTextProvider =
      Provider.of<UnsavedTextProvider>(context, listen: false);
  final editingPageKey = context.read<EditingProvider>();

  final unsaved = unsavedTextProvider.unsaved(
      frontmatterKeys: editingPageKey.frontmatterKeys);

  if (unsaved) {
    setClosingWindow?.call(true);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Localization.appLocalizations().quitWithUnsaved),
          content:
              Text(Localization.appLocalizations().quitWithUnsaved_Description),
          actionsOverflowButtonSpacing: 8.0,
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setClosingWindow?.call(false);
                },
                child: Text(Localization.appLocalizations().cancel)),
            ElevatedButton(
              onPressed: () async {
                await revertFileAndFrontmatter(context: context);
                shellProvider.kill();

                close();
              },
              child: Text(Localization.appLocalizations().revertAndQuit),
            ),
            ElevatedButton(
              onPressed: () async {
                await saveFileAndFrontmatter(context: context);
                shellProvider.kill();

                close();
              },
              child: Text(Localization.appLocalizations().saveAndQuit),
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
  final url = Uri(scheme: 'https', path: 'buhocms.org');
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
    applicationVersion: Localization.appLocalizations().version(
      '0.5.0 Alpha',
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
        child: SelectableText(Localization.appLocalizations().license),
      ),
    ],
  );
}
