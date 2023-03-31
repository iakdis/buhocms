import 'dart:io';

import 'package:buhocms/src/utils/preferences.dart';
import 'package:buhocms/src/utils/unsaved_check.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/l10n.dart';
import '../logic/buho_functions.dart';
import '../logic/files.dart';
import '../provider/editing/editing_provider.dart';
import '../provider/editing/tabs_provider.dart';
import '../provider/navigation/file_navigation_provider.dart';
import '../provider/navigation/navigation_provider.dart';
import '../utils/program_installed.dart';
import '../utils/terminal_command.dart';
import '../widgets/command_dialog.dart';
import '../widgets/snackbar.dart';

enum SSGTypes {
  hugo,
  jekyll,

  none,
}

class SSG {
  static Future<void> setSSG(SSGTypes ssg) async {
    await Preferences.setSSG(ssg.name);
  }

  static String getSSGContentFolder({
    required SSGTypes ssg,
    required bool pathSeparator,
  }) {
    String folder;

    switch (ssg) {
      case SSGTypes.hugo:
        folder = 'content';
        if (pathSeparator) folder = '${Platform.pathSeparator}$folder';
        break;
      case SSGTypes.jekyll:
        folder = '_posts';
        if (pathSeparator) folder = '${Platform.pathSeparator}$folder';
        break;
      default:
        folder = '';
        break;
    }

    return folder;
  }

  static Future<void> addSSGPostDialog({
    required BuildContext context,
    required bool mounted,
    required String path,
  }) async {
    show() async {
      String name = 'my-post';
      final TextEditingController nameController = TextEditingController();
      bool empty = false;
      String flags = '';

      final contentFolder = SSG.getSSGContentFolder(
          ssg: SSGTypes.values.byName(Preferences.getSSG()),
          pathSeparator: false);
      nameController.text = name;
      var allFiles = await getAllFiles();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            empty = name.isEmpty;
            final FocusNode nameFocusNode = FocusNode();
            nameFocusNode.requestFocus();
            nameController.selection = TextSelection(
                baseOffset: 0, extentOffset: nameController.text.length);
            var fileAlreadyExists = false;
            for (var i = 0; i < allFiles.length; i++) {
              if (allFiles[i].path ==
                  '$path${Platform.pathSeparator}$name.md') {
                fileAlreadyExists = true;
              }
            }

            return StatefulBuilder(builder: (context, setState) {
              return CommandDialog(
                title: SelectableText.rich(TextSpan(
                    text: Localization.appLocalizations().createNewPostIn,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                    children: <TextSpan>[
                      TextSpan(
                        text: path.substring(path.indexOf(contentFolder)),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ])),
                icon: Icons.note_add,
                expansionIcon: Icons.terminal,
                expansionTitle: Localization.appLocalizations().terminal,
                yes: empty
                    ? null
                    : () => SSG.addSSGPost(
                          context: context,
                          mounted: mounted,
                          path: path,
                          name: name,
                          flags: flags,
                        ),
                dialogChildren: [
                  CustomTextField(
                    leading: Text(Localization.appLocalizations().name,
                        style: const TextStyle(fontSize: 16)),
                    controller: nameController,
                    focusNode: nameFocusNode,
                    onChanged: (value) {
                      setState(() {
                        name = value;
                        empty = name.isEmpty;

                        for (var i = 0; i < allFiles.length; i++) {
                          if (allFiles[i].path ==
                              '$path${Platform.pathSeparator}$name.md') {
                            fileAlreadyExists = true;
                            return;
                          }
                        }
                        fileAlreadyExists = false;
                      });
                    },
                    suffixText: '             .md',
                    helperText: '"my-post"',
                    errorText: empty
                        ? Localization.appLocalizations().cantBeEmpty
                        : fileAlreadyExists
                            ? Localization.appLocalizations()
                                .error_fileAlreadyExists('"$name"',
                                    '"${path.substring(path.indexOf(contentFolder))}"')
                            : null,
                  )
                ],
                expansionChildren: [
                  CustomTextField(
                    leading: Text(Localization.appLocalizations().command),
                    controller: nameController,
                    onChanged: (value) {
                      setState(() {
                        name = value;
                        empty = name.isEmpty;

                        for (var i = 0; i < allFiles.length; i++) {
                          if (allFiles[i].path ==
                              '$path${Platform.pathSeparator}$name.md') {
                            fileAlreadyExists = true;
                            return;
                          }
                        }
                        fileAlreadyExists = false;
                      });
                    },
                    prefixText: 'hugo new ',
                    helperText: '"hugo new my-post"',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    leading: Text(Localization.appLocalizations().flags),
                    onChanged: (value) => setState(() => flags = value),
                    helperText: '"--force"',
                  ),
                ],
              );
            });
          },
        );
      }
    }

    checkUnsavedBeforeFunction(context: context, function: () => show());
  }

  static Future<void> addSSGPost({
    required BuildContext context,
    required bool mounted,
    required String path,
    required String name,
    required String flags,
  }) async {
    final tabsProvider = context.read<TabsProvider>();
    final fileNavigationProvider = context.read<FileNavigationProvider>();
    final navigationProvider = context.read<NavigationProvider>();
    final editingPageKey = context.read<EditingProvider>().editingPageKey;

    // Create post
    successFunction() {
      final snackbarText =
          Localization.appLocalizations().postCreated('"$name"', '"$path"');
      showSnackbar(text: snackbarText, seconds: 4);
      if (mounted) refreshFiles(context: context);
    }

    final contentFolder = SSG.getSSGContentFolder(
        ssg: SSGTypes.values.byName(Preferences.getSSG()),
        pathSeparator: false);
    var afterContent = '';
    var finalPathAndName = '';
    afterContent =
        path.substring(path.indexOf(contentFolder) + contentFolder.length);

    if (afterContent.isNotEmpty) {
      afterContent = afterContent.replaceAll(Platform.pathSeparator, '');
      finalPathAndName = '$afterContent${Platform.pathSeparator}$name.md';
    } else {
      finalPathAndName = '$name.md';
    }

    const executable = 'hugo';
    final allFlags = 'new $finalPathAndName $flags';
    checkProgramInstalled(
      context: context,
      executable: 'hugo',
      ssg: SSGTypes.values.byName(Preferences.getSSG()),
    );

    await runTerminalCommand(
      context: context,
      workingDirectory: Preferences.getSitePath(),
      executable: executable,
      flags: allFlags.split(' '),
      successFunction: () => successFunction(),
    );

    // Set File index
    var allFiles = await getAllFiles();
    var finalPath = '$path${Platform.pathSeparator}$name.md';

    for (var i = 0; i < allFiles.length; i++) {
      if (allFiles[i].path == finalPath) {
        fileNavigationProvider.setFileNavigationIndex(i);
        break;
      }
    }

    // Update EditingPage fields
    await fileNavigationProvider.setInitialTexts();
    await Preferences.setCurrentFile(finalPath);
    await Preferences.setCurrentPath(path);
    editingPageKey.currentState?.updateFrontmatterWidgets();

    //Scroll to tab
    final tabs = tabsProvider.tabs;
    tabs.add(MapEntry(finalPath, fileNavigationProvider.fileNavigationIndex));
    await tabsProvider.setTabs(tabs, updateFiles: true);

    if ((navigationProvider.navigationIndex ?? 0) > 0) return;
    tabsProvider.scrollToTab(
        fileNavigationIndex: fileNavigationProvider.fileNavigationIndex);

    // Close dialog
    if (mounted) Navigator.pop(context);
  }

  static Future<void> createSSGWebsite({
    required BuildContext context,
    required SSGTypes ssg,
    required String sitePath,
    required String siteName,
    required String flags,
  }) async {
    String? executable;
    String allFlags = '';
    switch (ssg) {
      case SSGTypes.hugo:
        executable = 'hugo';
        allFlags = 'new site $siteName';
        if (flags.isNotEmpty) allFlags += ' $flags';
        break;
      case SSGTypes.jekyll:
        executable = 'jekyll';
        allFlags = 'new $siteName';
        if (flags.isNotEmpty) allFlags += ' $flags';
        break;
      default:
        break;
    }

    if (executable == null) return;

    checkProgramInstalled(
      context: context,
      executable: getSSGExecutable(ssg),
      ssg: ssg,
    );
    await runTerminalCommand(
      context: context,
      workingDirectory: sitePath,
      executable: executable,
      flags: allFlags.split(' '),
    );
  }

  static String getCreateSiteSSGPrefix(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'hugo new site ';
      case SSGTypes.jekyll:
        return 'jekyll new ';
      default:
        return 'Get name: Unknown SSG';
    }
  }

  static String getCreateSiteSSGHelper(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return '"hugo new site my-website"';
      case SSGTypes.jekyll:
        return '"jekyll new myblog"';
      default:
        return 'Get name: Unknown SSG';
    }
  }

  static String getSSGName(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'Hugo';
      case SSGTypes.jekyll:
        return 'Jekyll';
      case SSGTypes.none:
        return 'None';
      default:
        return 'Get name: Unknown SSG';
    }
  }

  static String getSSGExecutable(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'hugo';
      case SSGTypes.jekyll:
        return 'jekyll';
      default:
        return 'Get executable: Unknown SSG';
    }
  }
}
