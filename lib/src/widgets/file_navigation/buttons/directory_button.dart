import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/buho_functions.dart';
import '../../../logic/files.dart';
import '../../../provider/navigation/file_navigation_provider.dart';
import '../../../provider/navigation/navigation_provider.dart';
import '../../../utils/preferences.dart';
import '../../../utils/unsaved_check.dart';
import '../../shortcuts.dart';
import '../../snackbar.dart';
import '../../tooltip.dart';
import '../context_menus/add_folder.dart';
import '../context_menus/context_menu_folder_button.dart';

class DirectoryButton extends StatefulWidget {
  const DirectoryButton({
    Key? key,
    required this.buttonText,
    required this.index,
    required this.path,
    required this.isExtended,
    required this.setStateCallback,
    required this.insideFolder,
  }) : super(key: key);

  final String buttonText;
  final int index;
  final String path;
  final bool isExtended;
  final Function setStateCallback;
  final bool insideFolder;

  @override
  State<DirectoryButton> createState() => _DirectoryButtonState();
}

class _DirectoryButtonState extends State<DirectoryButton> {
  TextEditingController controller = TextEditingController();
  late FocusNode focusNode;
  late FocusNode focusNodeButton;
  bool controllerEnabled = false;

  @override
  void initState() {
    controller.text = widget.buttonText;
    focusNode = FocusNode();
    focusNodeButton = FocusNode();

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() => controllerEnabled = false);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    focusNodeButton.dispose();

    super.dispose();
  }

  Future<void> rename(String text) async {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    focusNode.unfocus();
    controllerEnabled = false;
    final directory = Directory(widget.path);
    final lastSeparator = widget.path.lastIndexOf(Platform.pathSeparator);
    final newPath = widget.path.substring(0, lastSeparator + 1) + text;

    var allFiles = await getAllDirectories();
    for (var i = 0; i < allFiles.length; i++) {
      if (allFiles[i].path == newPath) {
        if (mounted) {
          showSnackbar(
            text: Localization.appLocalizations().error_RenameDirectory(
                '"${directory.path.split(Platform.pathSeparator).last}"',
                '"${newPath.split(Platform.pathSeparator).last}"'),
            seconds: 4,
          );
        }
        controller.text = widget.buttonText;
        return;
      }
    }

    await directory.rename(newPath);

    widget.setStateCallback();

    if (mounted) {
      showSnackbar(
        text: Localization.appLocalizations().renamedDirectory(
            '"${directory.path.split(Platform.pathSeparator).last}"',
            '"${newPath.split(Platform.pathSeparator).last}"'),
        seconds: 4,
      );

      fileNavigationProvider.setFileNavigationIndex(-1);
      await fileNavigationProvider.setInitialTexts();
      navigationProvider.setEditingPage();
    }
  }

  void _rename() {
    function() {
      setState(() {
        controllerEnabled = true;
      });
      focusNode.requestFocus();

      controller.selection =
          TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    }

    checkUnsavedBeforeFunction(context: context, function: () => function());
  }

  void _delete() {
    function() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(Localization.appLocalizations().deleteFolder),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SelectableText.rich(
              TextSpan(
                text: Localization.appLocalizations().deleteFolder_Description,
                children: <TextSpan>[
                  TextSpan(
                    text: widget.path,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Localization.appLocalizations().cancel),
            ),
            TextButton(
              onPressed: () async {
                final fileNavigationProvider =
                    Provider.of<FileNavigationProvider>(context, listen: false);
                final navigationProvider =
                    Provider.of<NavigationProvider>(context, listen: false);
                final directory = Directory(widget.path);
                await directory.delete(recursive: true);

                widget.setStateCallback();

                if (mounted) {
                  showSnackbar(
                    text: Localization.appLocalizations()
                        .deletedFolder('"${widget.path}"'),
                    seconds: 4,
                  );
                  Navigator.pop(context);

                  fileNavigationProvider.setFileNavigationIndex(-1);
                  await fileNavigationProvider.setInitialTexts();
                  navigationProvider.setEditingPage();
                }
              },
              child: Text(Localization.appLocalizations().yes),
            ),
          ],
        ),
      );
    }

    checkUnsavedBeforeFunction(context: context, function: () => function());
  }

  Widget navigationDirectoryButton() {
    return FutureBuilder(
        future: getAllFilesAndDirectoriesInDirectory(
            path: widget.path, recursive: false),
        builder: (context, snapshot) {
          return LayoutBuilder(builder: (context, constraints) {
            return Material(
              color: Colors.transparent,
              child: CustomTooltip(
                message: widget.path,
                child: GestureDetector(
                  onSecondaryTap: () {
                    context.contextMenuOverlay.show(
                      folderContextMenus(
                        context: context,
                        addFile: ContextMenuButtonConfig(
                            Localization.appLocalizations().newPost,
                            icon: const Icon(Icons.post_add, size: 20),
                            onPressed: () => addFile(
                                context: context,
                                mounted: mounted,
                                path: widget.path)),
                        addFolder: AddFolder(context, mounted)
                            .addFolderContextMenu(savePath: widget.path),
                        rename: () => _rename(),
                        openInFolder: () => openInFolder(
                            path: widget.path, keepPathTrailing: false),
                        delete: () => _delete(),
                      ),
                    );
                    focusNodeButton.requestFocus();
                  },
                  child: Shortcuts(
                    shortcuts: const <SingleActivator, Intent>{
                      SingleActivator(LogicalKeyboardKey.f2): RenameIntent(),
                      SingleActivator(LogicalKeyboardKey.delete):
                          DeleteIntent(),
                    },
                    child: Actions(
                      dispatcher: LoggingActionDispatcher(),
                      actions: <Type, Action<Intent>>{
                        RenameIntent: RenameAction(() {
                          _rename();
                          context.contextMenuOverlay.hide();
                        }),
                        DeleteIntent: DeleteAction(() {
                          _delete();
                          context.contextMenuOverlay.hide();
                        }),
                      },
                      child: Focus(
                        focusNode: focusNodeButton,
                        child: InkWell(
                          onTap: () {
                            Preferences.setCurrentPath(widget.path);
                            widget.setStateCallback();
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Padding(
                            padding: widget.isExtended
                                ? const EdgeInsets.fromLTRB(
                                    12.0, 8.0, 12.0, 8.0)
                                : const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment: widget.isExtended
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.center,
                                children: [
                                  if (widget.isExtended && widget.insideFolder)
                                    const SizedBox(width: 20.0),
                                  Icon(
                                    Icons.folder,
                                    size: 32.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  if (widget.isExtended)
                                    Row(
                                      children: [
                                        const SizedBox(width: 16.0),
                                        SizedBox(
                                          width: constraints.maxWidth -
                                              (widget.insideFolder ? 100 : 80),
                                          child: controllerEnabled
                                              ? TextField(
                                                  controller: controller,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                  autofocus: true,
                                                  focusNode: focusNode,
                                                  onSubmitted: (text) async =>
                                                      await rename(text),
                                                )
                                              : Text(
                                                  widget.buttonText,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) => navigationDirectoryButton();
}
