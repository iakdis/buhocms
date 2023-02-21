import 'dart:io';

import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:buhocms/src/ssg/hugo.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../logic/files.dart';
import '../../../pages/editing_page.dart';
import '../../../provider/editing/tabs_provider.dart';
import '../../../provider/navigation/file_navigation_provider.dart';
import '../../../provider/navigation/navigation_provider.dart';
import '../../../utils/preferences.dart';
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

  Shell newPostShell = Shell(workingDirectory: Preferences.getSitePath());
  String name = 'my-post';
  final TextEditingController nameController = TextEditingController();
  bool empty = false;

  Future<void> _addNew({required String path}) async {
    if (path == null) return;
    if (!path.contains('content')) return;

    print('Add Post at: $path');

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

    checkHugoInstalled(
      context: context,
      command: 'hugo new $finalPathAndName',
    );

    await newPostShell.run('''

          echo Start!

          # Add new hugo content
          hugo new $finalPathAndName

          ''');

    newPostShell.kill();

    if (mounted) refreshFiles(context: context);
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

    showSnackbar(
      context: context,
      text: AppLocalizations.of(context)!.postCreated('"$name"', '"$path"'),
      seconds: 4,
    );

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

          return LayoutBuilder(builder: (context, constraints) {
            return StatefulBuilder(builder: (context, setState) {
              return SimpleDialog(
                contentPadding:
                    const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
                children: [
                  Column(
                    children: [
                      const Icon(Icons.note_add, size: 64.0),
                      const SizedBox(height: 16.0),
                      SelectableText.rich(TextSpan(
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
                    ],
                  ),
                  const SizedBox(height: 32.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.name,
                                style: textStyle),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minWidth: 200, maxWidth: 300),
                              child: IntrinsicWidth(
                                child: TextField(
                                  controller: nameController,
                                  focusNode: nameFocusNode,
                                  onChanged: (value) {
                                    setState(() {
                                      name = value;
                                      empty = name.isEmpty;

                                      for (var i = 0;
                                          i < allFiles.length;
                                          i++) {
                                        if (allFiles[i].path ==
                                            '$path${Platform.pathSeparator}$name.md') {
                                          fileAlreadyExists = true;
                                          return;
                                        }
                                      }
                                      fileAlreadyExists = false;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    suffixText: '             .md',
                                    hintText: 'my-post',
                                    errorText: empty
                                        ? AppLocalizations.of(context)!
                                            .cantBeEmpty
                                        : fileAlreadyExists
                                            ? AppLocalizations.of(context)!
                                                .error_fileAlreadyExists(
                                                    '"$name"',
                                                    '"${path.substring(path.indexOf('content'))}"')
                                            : null,
                                    errorMaxLines: 5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                        onPressed: empty || fileAlreadyExists
                            ? null
                            : () => _create(
                                  path: path,
                                  setState: setState,
                                ),
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
