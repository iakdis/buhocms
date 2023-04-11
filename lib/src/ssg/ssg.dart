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
}

class SSG {
  static SSGTypes getSSGType(String ssg) => SSGTypes.values.byName(ssg);

  static Future<void> setSSG(SSGTypes ssg) async =>
      await Preferences.setSSG(ssg.name);

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
    }

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

            return StatefulBuilder(builder: (_, setState) {
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
          executable: executable,
          ssg: SSG.getSSGType(Preferences.getSSG()),
        );

        runTerminalCommand(
          context: context,
          workingDirectory: Preferences.getSitePath(),
          executable: executable,
          flags: allFlags.split(' '),
          successFunction: () => successFunction(),
        );
        break;
      case SSGTypes.jekyll:
        final fileName = '$path${Platform.pathSeparator}$name.md';
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

    if ((navigationProvider.navigationIndex ?? 0) > 0) return;
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
    String? executable;
    String allFlags = '';
    switch (ssg) {
      case SSGTypes.hugo:
        executable = 'hugo';
        allFlags = 'new site $siteName';
        if (flags.isNotEmpty) allFlags += ' $flags';
        break;
      case SSGTypes.jekyll:
        // Try to use scheme /home/user/gems/bin/jekyll, otherwise 'jekyll'
        executable = await checkProgramInstalled(
            context: context, executable: 'jekyll', ssg: ssg);
        executable ??= 'jekyll';
        allFlags = 'new $siteName';
        if (flags.isNotEmpty) allFlags += ' $flags';
        break;
    }

    if (mounted) {
      await runTerminalCommand(
        context: context,
        workingDirectory: sitePath,
        executable: executable,
        flags: allFlags.split(' '),
      );
    }
  }

  static String getCreateSiteSSGPrefix(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'hugo new site ';
      case SSGTypes.jekyll:
        return 'jekyll new ';
    }
  }

  static String getCreateSiteSSGHelper(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return '"hugo new site my-website"';
      case SSGTypes.jekyll:
        return '"jekyll new myblog"';
    }
  }

  static String getSSGName(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'Hugo';
      case SSGTypes.jekyll:
        return 'Jekyll';
    }
  }

  static String getSSGExecutable(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'hugo';
      case SSGTypes.jekyll:
        return 'jekyll';
    }
  }
}
