import 'dart:io';

import 'package:buhocms/src/logic/files.dart';
import 'package:buhocms/src/pages/theme_page.dart';
import 'package:buhocms/src/provider/app/shell_provider.dart';
import 'package:buhocms/src/provider/editing/unsaved_text_provider.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../i18n/l10n.dart';
import '../pages/create_website.dart';
import '../pages/open_website.dart';
import '../provider/editing/editing_provider.dart';
import '../provider/navigation/file_navigation_provider.dart';
import '../provider/navigation/navigation_provider.dart';
import '../ssg/ssg.dart';
import '../utils/preferences.dart';
import '../utils/unsaved_check.dart';
import '../widgets/file_navigation/context_menus/add_folder.dart';
import '../widgets/snackbar.dart';

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
  String? path,
}) =>
    SSG.addSSGPostDialog(
        context: context,
        mounted: mounted,
        path: path ?? Preferences.getCurrentPath(),
        ssg: SSG.getSSGType(Preferences.getSSG()));

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

void openWebsite({required BuildContext context, Function? setState}) {
  Navigator.push(
          context, MaterialPageRoute(builder: (context) => const OpenWebsite()))
      .then((value) => setState?.call());
}

void createWebsite({required BuildContext context, Function? setState}) {
  Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CreateWebsite()))
      .then((value) => setState?.call());
}

void openHugoThemes({required BuildContext context, Function? setState}) {
  Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ThemePage()))
      .then((value) => setState?.call());
}

void startLiveServer({required BuildContext context}) =>
    SSG.startSSGServerDialog(
        context: context, ssg: SSG.getSSGType(Preferences.getSSG()));

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

void openLocalhost() =>
    SSG.openSSGLiveServer(ssg: SSG.getSSGType(Preferences.getSSG()));

void buildWebsite({required BuildContext context}) async {
  SSG.buildSSGWebsiteDialog(
      context: context, ssg: SSG.getSSGType(Preferences.getSSG()));
}

void openBuildFolder() =>
    SSG.openSSGBuildFolder(ssg: SSG.getSSGType(Preferences.getSSG()));

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

void about({required BuildContext context, required bool mounted}) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if (mounted) {
    showAboutDialog(
      context: context,
      applicationName: 'BuhoCMS',
      applicationVersion: Localization.appLocalizations().version(
        '${packageInfo.version} Alpha', //TODO remove Alpha once ready
      ),
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
}

void fullScreen(WindowManager windowManager) async {
  final isFullScreen = await windowManager.isFullScreen();
  if (!isFullScreen) {
    await windowManager.setFullScreen(true);
    showSnackbar(
        text: Localization.appLocalizations().fullScreenInfo, seconds: 3);
  } else {
    await windowManager.setFullScreen(false);
  }
}
