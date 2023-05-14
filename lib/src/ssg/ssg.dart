import 'dart:io';

import 'package:buhocms/src/utils/preferences.dart';
import 'package:buhocms/src/utils/unsaved_check.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../i18n/l10n.dart';
import '../logic/buho_functions.dart';
import '../logic/files.dart';
import '../provider/app/shell_provider.dart';
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
  eleventy,
}

class SSG {
  static SSGTypes getSSGType(String ssg) => SSGTypes.values.byName(ssg);

  static Future<void> setSSG(SSGTypes ssg) async =>
      await Preferences.setSSG(ssg.name);

  static Map<String, String> defaultSSGContentList() {
    return {
      SSGTypes.hugo.name: 'content',
      SSGTypes.jekyll.name: '_posts',
      SSGTypes.eleventy.name: 'posts',
    };
  }

  static String getSSGContentFolder({
    required SSGTypes ssg,
    required bool pathSeparator,
  }) {
    final contentSSGList = Preferences.getSSGContentList();

    var folder = contentSSGList[ssg] ?? 'content';
    if (pathSeparator) folder = '${Platform.pathSeparator}$folder';

    return folder;
  }

  static String getSSGBuildFolder({required SSGTypes ssg}) {
    final websitePath = Preferences.getSitePath();
    if (websitePath == null) return '';

    switch (ssg) {
      case SSGTypes.hugo:
        return '$websitePath${Platform.pathSeparator}public';
      case SSGTypes.jekyll:
        return '$websitePath${Platform.pathSeparator}_site';
      case SSGTypes.eleventy:
        return '$websitePath${Platform.pathSeparator}_site';
    }
  }

  static Future<void> openSSGBuildFolder({required SSGTypes ssg}) async {
    if (getSSGBuildFolder(ssg: ssg).isEmpty) return;
    final uri = Uri(path: getSSGBuildFolder(ssg: ssg), scheme: 'file');
    if (await canLaunchUrl(uri) || Platform.isLinux) await launchUrl(uri);
  }

  static String getSSGLiveServer({required SSGTypes ssg}) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'http://localhost:1313';
      case SSGTypes.jekyll:
        return 'http://localhost:4000';
      case SSGTypes.eleventy:
        return 'http://localhost:8080';
    }
  }

  static Future<void> openSSGLiveServer({required SSGTypes ssg}) async {
    final uri = Uri.parse(getSSGLiveServer(ssg: ssg));
    if (await canLaunchUrl(uri) || Platform.isLinux) await launchUrl(uri);
  }

  static Future<void> buildSSGWebsiteDialog({
    required BuildContext context,
    required SSGTypes ssg,
  }) async {
    final commandTextController = TextEditingController();
    final String command;

    var currentFlags = '';
    final String exampleFlags;

    switch (ssg) {
      case SSGTypes.hugo:
        command = 'hugo';
        exampleFlags = '--buildDrafts';
        break;
      case SSGTypes.jekyll:
        command = 'bundle exec jekyll build';
        exampleFlags = '--drafts';
        break;
      case SSGTypes.eleventy:
        command = 'npx';
        exampleFlags = '--help';
        break;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return CommandDialog(
            title: Text(
              Localization.appLocalizations().buildWebsite(SSG.getSSGName(ssg)),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            icon: Icons.web,
            expansionIcon: Icons.terminal,
            expansionTitle: Localization.appLocalizations().terminal,
            yes: () => buildSSGWebsite(
                context: context, flags: currentFlags, ssg: ssg),
            dialogChildren: const [],
            expansionChildren: [
              CustomTextField(
                readOnly: true,
                controller: commandTextController,
                leading: Text(Localization.appLocalizations().command),
                initialText: command,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                leading: Text(Localization.appLocalizations().flags),
                onChanged: (value) => setState(() => currentFlags = value),
                helperText: '"$exampleFlags"',
              ),
            ],
          );
        });
      },
    );
  }

  static Future<void> buildSSGWebsite({
    required BuildContext context,
    required String flags,
    required SSGTypes ssg,
  }) async {
    final String executable;
    final List<String> commandFlags;
    switch (ssg) {
      case SSGTypes.hugo:
        executable = 'hugo';
        commandFlags = flags.split(' ');
        break;
      case SSGTypes.jekyll:
        executable = 'bundle';
        commandFlags = 'exec jekyll build $flags'.split(' ');
        break;
      case SSGTypes.eleventy:
        executable = 'npx';
        commandFlags =
            '@11ty/eleventy${flags.isNotEmpty ? " $flags" : ""}'.split(' ');
        break;
    }

    checkProgramInstalled(
      context: context,
      executable: executable,
      ssg: SSG.getSSGType(Preferences.getSSG()),
    );

    runTerminalCommand(
      context: context,
      workingDirectory: Preferences.getSitePath(),
      executable: executable,
      flags: commandFlags,
      successFunction: () => showSnackbar(
        text: Localization.appLocalizations().builtWebsite(getSSGName(ssg)),
        seconds: 4,
      ),
    );

    Navigator.pop(context);
  }

  static Future<void> startSSGServerDialog({
    required BuildContext context,
    required SSGTypes ssg,
  }) async {
    final commandTextController = TextEditingController();
    final String command;

    var currentFlags = '';
    final String exampleFlags;

    switch (ssg) {
      case SSGTypes.hugo:
        command = 'hugo server';
        exampleFlags = '--theme hugo-PaperMod';
        break;
      case SSGTypes.jekyll:
        command = 'bundle exec jekyll serve';
        exampleFlags = '--livereload';
        break;
      case SSGTypes.eleventy:
        command = 'npx @11ty/eleventy --serve';
        exampleFlags = '--help';
        break;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return CommandDialog(
            title: Text(
              Localization.appLocalizations().startLiveServer,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            icon: Icons.miscellaneous_services,
            expansionIcon: Icons.terminal,
            expansionTitle: Localization.appLocalizations().terminal,
            yes: () =>
                startSSGServer(context: context, ssg: ssg, flags: currentFlags),
            dialogChildren: const [],
            expansionChildren: [
              CustomTextField(
                readOnly: true,
                controller: commandTextController,
                leading: Text(Localization.appLocalizations().command),
                initialText: command,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                leading: Text(Localization.appLocalizations().flags),
                onChanged: (value) => setState(() => currentFlags = value),
                helperText: '"$exampleFlags"',
              ),
            ],
          );
        });
      },
    );
  }

  static Future<void> startSSGServer({
    required BuildContext context,
    required String flags,
    required SSGTypes ssg,
  }) async {
    final String executable;
    final List<String> commandFlags;
    switch (ssg) {
      case SSGTypes.hugo:
        executable = 'hugo';
        commandFlags = 'server $flags'.split(' ');
        break;
      case SSGTypes.jekyll:
        executable = 'bundle';
        commandFlags = 'exec jekyll serve $flags'.split(' ');
        break;
      case SSGTypes.eleventy:
        executable = 'npx';
        commandFlags = '@11ty/eleventy --serve $flags'.split(' ');
        break;
    }
    final shellProvider = context.read<ShellProvider>();
    checkProgramInstalled(
      context: context,
      executable: executable,
      ssg: SSG.getSSGType(Preferences.getSSG()),
    );

    shellProvider.updateController();

    runTerminalCommandServer(
      context: context,
      shell: shellProvider.shell(),
      controller: shellProvider.controller,
      successFunction: () => shellProvider.setShellActive(true),
      errorFunction: () => shellProvider.setShellActive(false),
      executable: executable,
      flags: commandFlags,
      snackbarFunction: () => showSnackbar(
        text: shellProvider.shellActive == true
            ? Localization.appLocalizations().alreadyStartedLiveServer
            : Localization.appLocalizations().startedLiveServer,
        seconds: 4,
      ),
    );

    Navigator.pop(context);
  }

  static Future<void> addSSGPostDialog({
    required BuildContext context,
    required bool mounted,
    required String path,
    required SSGTypes ssg,
  }) async {
    show() async {
      final String defaultName;
      final bool showTerminal;
      final bool canOverride;
      switch (ssg) {
        case SSGTypes.hugo:
          defaultName = 'my-post';
          showTerminal = true;
          canOverride = true;
          break;
        case SSGTypes.jekyll:
          final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
          defaultName = '$date-my-new-post';
          showTerminal = false;
          canOverride = false;
          break;
        case SSGTypes.eleventy:
          defaultName = 'my-post';
          showTerminal = false;
          canOverride = false;
          break;
      }

      final TextEditingController nameController = TextEditingController();
      bool empty = false;
      String flags = '';
      String name = defaultName;

      final contentFolder = getSSGContentFolder(
          ssg: SSG.getSSGType(Preferences.getSSG()), pathSeparator: false);
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
                title: SizedBox(
                  width: 300,
                  child: SelectableText.rich(TextSpan(
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
                ),
                icon: Icons.note_add,
                expansionIcon: Icons.terminal,
                expansionTitle: Localization.appLocalizations().terminal,
                yes: empty || (fileAlreadyExists && !canOverride)
                    ? null
                    : () => addSSGPost(
                          context: context,
                          mounted: mounted,
                          path: path,
                          name: name,
                          flags: flags,
                          ssg: ssg,
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
                    suffixText: '.md',
                    helperText: '"$defaultName"',
                    errorText: empty
                        ? Localization.appLocalizations().cantBeEmpty
                        : fileAlreadyExists
                            ? Localization.appLocalizations()
                                .error_fileAlreadyExists('"$name"',
                                    '"${path.substring(path.indexOf(contentFolder))}"')
                            : null,
                  )
                ],
                expansionChildren: showTerminal
                    ? [
                        CustomTextField(
                          leading:
                              Text(Localization.appLocalizations().command),
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
                          helperText: '"hugo new $defaultName"',
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          leading: Text(Localization.appLocalizations().flags),
                          onChanged: (value) => setState(() => flags = value),
                          helperText: '"--force"',
                        ),
                      ]
                    : null,
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
    required SSGTypes ssg,
  }) async {
    final tabsProvider = context.read<TabsProvider>();
    final fileNavigationProvider = context.read<FileNavigationProvider>();
    final navigationProvider = context.read<NavigationProvider>();
    final editingPageKey = context.read<EditingProvider>().editingPageKey;

    successFunction() {
      final snackbarText =
          Localization.appLocalizations().postCreated('"$name"', '"$path"');
      showSnackbar(text: snackbarText, seconds: 4);
      if (mounted) refreshFiles(context: context);
    }

    final contentFolder = getSSGContentFolder(ssg: ssg, pathSeparator: false);

    // Create post
    switch (ssg) {
      case SSGTypes.hugo:
        final afterContent =
            path.substring(path.indexOf(contentFolder) + contentFolder.length);
        final finalPathAndName =
            '$contentFolder$afterContent${Platform.pathSeparator}$name.md';

        const executable = 'hugo';
        final allFlags = 'new $finalPathAndName $flags';
        checkProgramInstalled(
          context: context,
          executable: executable,
          ssg: SSG.getSSGType(Preferences.getSSG()),
        );

        await runTerminalCommand(
          context: context,
          workingDirectory: Preferences.getSitePath(),
          executable: executable,
          flags: allFlags.split(' '),
          successFunction: () => successFunction(),
        );
        break;
      case SSGTypes.jekyll:
        final fileName = '$path${Platform.pathSeparator}$name.md';
        if (!await Directory(path).exists()) await Directory(path).create();

        try {
          await File(fileName).create();
        } catch (e) {
          showSnackbar(text: 'Exception: $e', seconds: 10);
        }
        successFunction();
        break;
      case SSGTypes.eleventy:
        final fileName = '$path${Platform.pathSeparator}$name.md';
        if (!await Directory(path).exists()) await Directory(path).create();

        try {
          await File(fileName).create();
        } catch (e) {
          showSnackbar(text: 'Exception: $e', seconds: 10);
        }
        successFunction();
        break;
    }

    // Close dialog
    if (mounted) Navigator.pop(context);

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

    if (navigationProvider.navigationPage == NavigationPage.settings) return;
    tabsProvider.scrollToTab(
        fileNavigationIndex: fileNavigationProvider.fileNavigationIndex);
  }

  static Future<void> createSSGWebsite({
    required BuildContext context,
    required bool mounted,
    required SSGTypes ssg,
    required String sitePath,
    required String siteName,
    required String flags,
  }) async {
    Future<void> runCommand(BuildContext context, String executable,
        String allFlags, String sitePath) async {
      await runTerminalCommand(
        context: context,
        workingDirectory: sitePath,
        executable: executable,
        flags: allFlags.split(' '),
      );
    }

    String? executable;
    String allFlags = '';
    switch (ssg) {
      case SSGTypes.hugo:
        executable = 'hugo';
        allFlags = 'new site $siteName';
        if (flags.isNotEmpty) allFlags += ' $flags';

        await runCommand(context, executable, allFlags, sitePath);
        break;
      case SSGTypes.jekyll:
        // Try to use scheme /home/user/gems/bin/jekyll, otherwise 'jekyll'
        executable = await checkProgramInstalled(
            context: context, executable: 'jekyll', ssg: ssg);
        executable ??= 'jekyll';
        allFlags = 'new $siteName';
        if (flags.isNotEmpty) allFlags += ' $flags';

        if (mounted) {
          await runCommand(context, executable, allFlags, sitePath);
        }
        break;
      case SSGTypes.eleventy:
        executable = 'mkdir';
        allFlags = siteName;

        runCommand(context, executable, allFlags, sitePath);

        executable = 'npm';
        allFlags = 'init -y';
        if (flags.isNotEmpty) allFlags += ' $flags';

        runCommand(context, executable, allFlags,
            '$sitePath${Platform.pathSeparator}$siteName');

        executable = 'npm';
        allFlags = 'install @11ty/eleventy --save-dev';
        if (flags.isNotEmpty) allFlags += ' $flags';

        await runCommand(context, executable, allFlags,
            '$sitePath${Platform.pathSeparator}$siteName');
        break;
    }
  }

  static String getCreateSiteSSGPrefix(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'hugo new site ';
      case SSGTypes.jekyll:
        return 'jekyll new ';
      case SSGTypes.eleventy:
        return 'npm install @11ty/eleventy --save-dev ';
    }
  }

  static String getCreateSiteSSGHelper(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return '"hugo new site my-website"';
      case SSGTypes.jekyll:
        return '"jekyll new myblog"';
      case SSGTypes.eleventy:
        return 'npm install @11ty/eleventy --save-dev my-blog';
    }
  }

  static String getSSGName(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'Hugo';
      case SSGTypes.jekyll:
        return 'Jekyll';
      case SSGTypes.eleventy:
        return '11ty';
    }
  }

  static List<String> getSSGExecutable(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return ['hugo'];
      case SSGTypes.jekyll:
        return ['jekyll'];
      case SSGTypes.eleventy:
        return ['npm', 'npx'];
    }
  }
}
