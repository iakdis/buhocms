import 'dart:io';

import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:buhocms/src/widgets/command_dialog.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../logic/files.dart';
import '../../../pages/editing_page.dart';
import '../../../provider/editing/tabs_provider.dart';
import '../../../provider/navigation/file_navigation_provider.dart';
import '../../../provider/navigation/navigation_provider.dart';
import '../../../utils/preferences.dart';
import '../../../utils/program_installed.dart';
import '../../../utils/terminal_command.dart';
import '../../../utils/unsaved_check.dart';
import '../../snackbar.dart';

const TextStyle textStyle = TextStyle(fontSize: 16);

class AddFile {
  AddFile(this.context, this.mounted, this.editingPageKey,
      this.fileNavigationProvider);

  final BuildContext context;
  final bool mounted;
  final GlobalKey<EditingPageState> editingPageKey;
  final FileNavigationProvider fileNavigationProvider;

  String name = 'my-post';
  final TextEditingController nameController = TextEditingController();
  bool empty = false;
  String flags = '';

  Future<void> _addNew({required String path}) async {
    if (path == null) return;
    if (!path.contains('content')) return;

    print('Add Post at: $path');

    final snackbarText =
        AppLocalizations.of(context)!.postCreated('"$name"', '"$path"');
    var postDirectory = '';
    var finalPathAndName = '';

    postDirectory = path.substring(path.indexOf('content') + 7);

    if (postDirectory.isNotEmpty) {
      if (postDirectory.startsWith(Platform.pathSeparator)) {
        postDirectory = postDirectory.substring(1, postDirectory.length);
      }
      if (postDirectory.endsWith(Platform.pathSeparator)) {
        postDirectory = postDirectory.substring(0, postDirectory.length - 1);
      }

      print('hugo new $postDirectory${Platform.pathSeparator}$name.md');
      finalPathAndName = '$postDirectory${Platform.pathSeparator}$name.md';
    } else {
      print('hugo new $name.md');
      finalPathAndName = '$name.md';
    }

    final commandToRun = 'hugo new $finalPathAndName $flags';
    checkProgramInstalled(
      context: context,
      command: commandToRun,
      executable: 'hugo',
    );

    await runTerminalCommand(
      context: context,
      workingDirectory: Preferences.getSitePath(),
      command: commandToRun,
      successFunction: () {
        showSnackbar(
          text: snackbarText,
          seconds: 4,
        );
        if (mounted) refreshFiles(context: context);
      },
    );
  }

  void _create({
    required String path,
    required Function(void Function()) setState,
  }) async {
    final tabsProvider = Provider.of<TabsProvider>(context, listen: false);
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    setState(() => empty = name.isEmpty);
    if (empty) return;

    Navigator.pop(context);

    await _addNew(path: path);

    var allFiles = await getAllFiles();
    var finalPath = '$path${Platform.pathSeparator}$name.md';

    for (var i = 0; i < allFiles.length; i++) {
      if (allFiles[i].path == finalPath) {
        fileNavigationProvider.setFileNavigationIndex(i);
        break;
      }
    }

    await fileNavigationProvider.setInitialTexts();
    await Preferences.setCurrentFile(finalPath);
    await Preferences.setCurrentPath(path);
    editingPageKey.currentState?.updateHugoWidgets();

    final tabs = tabsProvider.tabs;
    tabs.add(MapEntry(finalPath, fileNavigationProvider.fileNavigationIndex));
    await tabsProvider.setTabs(tabs, updateFiles: true);

    if ((navigationProvider.navigationIndex ?? 0) > 0) return;
    tabsProvider.scrollToTab(
        fileNavigationIndex: fileNavigationProvider.fileNavigationIndex);
  }

  void _newFileDialog({required String path}) async {
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
            if (allFiles[i].path == '$path${Platform.pathSeparator}$name.md') {
              fileAlreadyExists = true;
            }
          }

          return StatefulBuilder(builder: (context, setState) {
            return CommandDialog(
              title: SelectableText.rich(TextSpan(
                  text: AppLocalizations.of(context)!.createNewPostIn,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                  children: <TextSpan>[
                    TextSpan(
                      text: path.substring(path.indexOf('content')),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ])),
              icon: Icons.note_add,
              expansionIcon: Icons.terminal,
              expansionTitle: AppLocalizations.of(context)!.terminal,
              yes: empty
                  ? null
                  : () => _create(
                        path: path,
                        setState: setState,
                      ),
              dialogChildren: [
                CustomTextField(
                  leading: Text(AppLocalizations.of(context)!.name,
                      style: textStyle),
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
                      ? AppLocalizations.of(context)!.cantBeEmpty
                      : fileAlreadyExists
                          ? AppLocalizations.of(context)!
                              .error_fileAlreadyExists('"$name"',
                                  '"${path.substring(path.indexOf('content'))}"')
                          : null,
                )
              ],
              expansionChildren: [
                CustomTextField(
                  leading: Text(AppLocalizations.of(context)!.command),
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
                  leading: Text(AppLocalizations.of(context)!.flags),
                  onChanged: (value) {
                    setState(() {
                      flags = value;
                    });
                  },
                  helperText: '"--force"',
                ),
              ],
            );
          });
        },
      );
    }
  }

  void newFile(
      {required String path,
      required GlobalKey<EditingPageState> editingPageKey}) {
    checkUnsavedBeforeFunction(
        editingPageKey: editingPageKey,
        function: () => _newFileDialog(path: path));
  }

  ContextMenuButtonConfig addFileContextMenu({required String savePath}) {
    return ContextMenuButtonConfig(
      AppLocalizations.of(context)!.newPost,
      icon: const Icon(Icons.post_add, size: 20),
      onPressed: () {
        newFile(path: savePath, editingPageKey: editingPageKey);
        //_newFolder(path:'${Preferences.getSavePath()}');
      },
    );
  }
}
