import 'dart:io';

import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/files.dart';
import '../../../ssg/ssg.dart';
import '../../../utils/preferences.dart';
import '../../../utils/unsaved_check.dart';
import '../../command_dialog.dart';
import '../../snackbar.dart';

const TextStyle textStyle = TextStyle(fontSize: 16);

class AddFolder {
  AddFolder(this.context, this.mounted);

  final BuildContext context;
  final bool mounted;

  String folderName = 'posts';
  final TextEditingController folderNameController = TextEditingController();

  void _newFolderDialog({required String path}) async {
    final contentFolder = SSG.getSSGContentFolder(
        ssg: SSG.getSSGType(Preferences.getSSG()), pathSeparator: false);
    folderNameController.text = folderName;
    var allFolders = await getAllDirectories();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          var empty = folderName.isEmpty;
          final FocusNode nameFocusNode = FocusNode();
          nameFocusNode.requestFocus();
          folderNameController.selection = TextSelection(
              baseOffset: 0, extentOffset: folderNameController.text.length);

          var folderAlreadyExists = false;
          for (var i = 0; i < allFolders.length; i++) {
            if (allFolders[i].path ==
                '$path${Platform.pathSeparator}$folderName') {
              folderAlreadyExists = true;
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
                      const Icon(Icons.create_new_folder, size: 64.0),
                      const SizedBox(height: 16.0),
                      SelectableText.rich(TextSpan(
                          text:
                              Localization.appLocalizations().createNewFolderIn,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                          children: <TextSpan>[
                            TextSpan(
                              text: path.substring(path.indexOf(contentFolder)),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ])),
                    ],
                  ),
                  const SizedBox(height: 32.0),
                  CustomTextField(
                    leading: Text(Localization.appLocalizations().name,
                        style: textStyle),
                    controller: folderNameController,
                    focusNode: nameFocusNode,
                    onChanged: (value) {
                      setState(() {
                        folderName = value;
                        empty = folderName.isEmpty;

                        for (var i = 0; i < allFolders.length; i++) {
                          if (allFolders[i].path ==
                              '$path${Platform.pathSeparator}$folderName') {
                            folderAlreadyExists = true;
                            return;
                          }
                        }
                        folderAlreadyExists = false;
                      });
                    },
                    helperText: '"posts"',
                    errorText: empty
                        ? Localization.appLocalizations().cantBeEmpty
                        : folderAlreadyExists
                            ? Localization.appLocalizations()
                                .error_folderAlreadyExists('"$folderName"',
                                    '"${path.substring(path.indexOf(contentFolder))}"')
                            : null,
                  ),
                  const SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(Localization.appLocalizations().cancel),
                      ),
                      TextButton(
                        onPressed: empty || folderAlreadyExists
                            ? null
                            : () async {
                                setState(() => empty = folderName.isEmpty);
                                if (empty) return;

                                var finalPath =
                                    '${Preferences.getCurrentPath()}${Platform.pathSeparator}$folderName';

                                showSnackbar(
                                  text: Localization.appLocalizations()
                                      .folderCreated('"$finalPath"'),
                                  seconds: 4,
                                );

                                Navigator.pop(context);

                                Directory(finalPath).createSync();

                                refreshFiles(context: context);
                              },
                        child: Text(Localization.appLocalizations().yes),
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

  void newFolder({required String path}) {
    checkUnsavedBeforeFunction(
        context: context, function: () => _newFolderDialog(path: path));
  }

  ContextMenuButtonConfig addFolderContextMenu({required String savePath}) {
    return ContextMenuButtonConfig(
      Localization.appLocalizations().newFolder,
      icon: const Icon(Icons.create_new_folder_outlined, size: 20),
      onPressed: () => newFolder(path: savePath),
    );
  }
}
