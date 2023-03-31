import 'dart:io';

import 'package:buhocms/src/provider/editing/tabs_provider.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/files.dart';
import '../../../provider/editing/editing_provider.dart';
import '../../../provider/navigation/file_navigation_provider.dart';
import '../../../provider/navigation/navigation_provider.dart';
import '../../../utils/preferences.dart';
import '../../../utils/unsaved_check.dart';
import '../../shortcuts.dart';
import '../../snackbar.dart';
import '../../tooltip.dart';
import '../context_menus/context_menu_file_button.dart';

class FileButton extends StatefulWidget {
  const FileButton({
    Key? key,
    required this.buttonText,
    required this.index,
    required this.path,
    required this.isExtended,
    required this.insideFolder,
    required this.setStateCallback,
  }) : super(key: key);

  final String buttonText;
  final int index;
  final String path;
  final bool isExtended;
  final bool insideFolder;
  final Function setStateCallback;

  @override
  State<FileButton> createState() => _FileButtonState();
}

class _FileButtonState extends State<FileButton> {
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
      if (!focusNode.hasFocus) setState(() => controllerEnabled = false);
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
    final tabsProvider = Provider.of<TabsProvider>(context, listen: false);
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    focusNode.unfocus();
    controllerEnabled = false;
    final file = File(widget.path);
    final lastSeparator = file.path.lastIndexOf(Platform.pathSeparator);
    final newPath = file.path.substring(0, lastSeparator + 1) + text;

    var allFiles = await getAllFiles();
    for (var i = 0; i < allFiles.length; i++) {
      if (allFiles[i].path == newPath) {
        if (mounted) {
          showSnackbar(
            text: Localization.appLocalizations().error_RenameFile(
                '"${file.path.split(Platform.pathSeparator).last}"',
                '"${newPath.split(Platform.pathSeparator).last}"'),
            seconds: 4,
          );
        }
        controller.text = widget.buttonText;
        return;
      }
    }

    await file.rename(newPath);

    if (mounted) {
      showSnackbar(
        text: Localization.appLocalizations().renamedFile(
            '"${file.path.split(Platform.pathSeparator).last}"',
            '"${newPath.split(Platform.pathSeparator).last}"'),
        seconds: 4,
      );
    }

    allFiles = await getAllFiles();

    var tabIndex = 0;
    for (var i = 0; i < tabsProvider.tabs.length; i++) {
      if (tabsProvider.tabs[i].value == widget.index) {
        tabIndex = i;
        tabsProvider.removeTab(tabIndex,
            navIndex: navigationProvider.navigationIndex ?? 0);
      }
    }

    if (widget.path == Preferences.getCurrentFile()) {
      for (var i = 0; i < allFiles.length; i++) {
        if (allFiles[i].path == newPath) {
          _openInNewTab(index: i, path: newPath, insertAt: tabIndex);
          break;
        }
      }
      await Preferences.setCurrentFile(newPath);
    }

    widget.setStateCallback();
  }

  void _scrollToTab() {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    if ((navigationProvider.navigationIndex ?? 0) > 0) return;
    final tabsProvider = Provider.of<TabsProvider>(context, listen: false);
    tabsProvider.scrollToTab(
        fileNavigationIndex: fileNavigationProvider.fileNavigationIndex);
  }

  void _open() {
    _openInNewTab(
      index: widget.index,
      path: widget.path,
    );
  }

  void _openInNewTab({
    required int index,
    required String path,
    int? insertAt,
  }) {
    checkUnsavedBeforeFunction(
      context: context,
      function: () async {
        final tabsProvider = Provider.of<TabsProvider>(context, listen: false);
        final fileNavigationProvider =
            Provider.of<FileNavigationProvider>(context, listen: false);
        final editingPageKey = context.read<EditingProvider>().editingPageKey;

        fileNavigationProvider.setFileNavigationIndex(index);
        await Preferences.setCurrentFile(path);
        await fileNavigationProvider.setInitialTexts();
        editingPageKey.currentState?.updateFrontmatterWidgets();

        final tabs = tabsProvider.tabs;
        final insertAtNormal = tabs.length - 1 >= 0 ? tabs.length : 0;
        tabs.insert(insertAt ?? insertAtNormal, MapEntry(path, index));
        await tabsProvider.setTabs(tabs, updateFiles: true);

        if (mounted) _scrollToTab();
      },
    );
    focusNodeButton.requestFocus();
  }

  void _rename() {
    function() {
      setState(() => controllerEnabled = true);
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
          title: Text(Localization.appLocalizations().deleteFile),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SelectableText.rich(
              TextSpan(
                text: Localization.appLocalizations().deleteFile_Description,
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
                final tabsProvider =
                    Provider.of<TabsProvider>(context, listen: false);
                final navigationProvider =
                    Provider.of<NavigationProvider>(context, listen: false);

                final file = File(widget.path);
                await file.delete();

                widget.setStateCallback();

                if (mounted) {
                  showSnackbar(
                    text: Localization.appLocalizations()
                        .deletedFile('"${widget.path}"'),
                    seconds: 4,
                  );
                  Navigator.pop(context);
                }

                if (widget.path == Preferences.getCurrentFile()) {
                  fileNavigationProvider.setFileNavigationIndex(-1);
                  await fileNavigationProvider.setInitialTexts();
                }

                for (var i = 0; i < tabsProvider.tabs.length; i++) {
                  if (tabsProvider.tabs[i].value == widget.index) {
                    tabsProvider.removeTab(i,
                        navIndex: navigationProvider.navigationIndex ?? 0);
                  }
                }
              },
              child: Text(Localization.appLocalizations().yes),
            ),
          ],
        ),
      );
    }

    if (mounted) {
      checkUnsavedBeforeFunction(context: context, function: () => function());
    }
  }

  Widget navigationButton() {
    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        color: Colors.transparent,
        child: CustomTooltip(
          message: widget.path,
          child: Consumer<FileNavigationProvider>(
              builder: (context, fileNavigationProvider, _) {
            return GestureDetector(
              onSecondaryTap: () {
                context.contextMenuOverlay.show(
                  fileContextMenus(
                    context: context,
                    open: () => _open(),
                    rename: () => _rename(),
                    openInFolder: () => openInFolder(
                        path: widget.path, keepPathTrailing: false),
                    delete: () => _delete(),
                  ),
                );
                focusNodeButton.requestFocus();
              },
              onTertiaryTapDown: (details) => _open(),
              child: Shortcuts(
                shortcuts: const <SingleActivator, Intent>{
                  SingleActivator(LogicalKeyboardKey.f2): RenameIntent(),
                  SingleActivator(LogicalKeyboardKey.delete): DeleteIntent(),
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
                      borderRadius: BorderRadius.circular(50),
                      onTap: widget.index ==
                              fileNavigationProvider.fileNavigationIndex
                          ? () {
                              _scrollToTab();
                              focusNodeButton.requestFocus();
                            }
                          : () => _open(),
                      child: Padding(
                        padding: widget.isExtended
                            ? const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0)
                            : const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: widget.isExtended
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            if (widget.isExtended && widget.insideFolder)
                              const SizedBox(width: 20.0),
                            Icon(
                              Icons.text_snippet_outlined,
                              size: 32.0,
                              color: widget.index ==
                                      fileNavigationProvider.fileNavigationIndex
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                  : Theme.of(context).colorScheme.onSecondary,
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
                                            //enabled: controllerEnabled,
                                            autofocus: true,
                                            focusNode: focusNode,
                                            onSubmitted: (text) async {
                                              await rename('$text.md');
                                            },
                                          )
                                        : Text(
                                            widget.buttonText,
                                            style: TextStyle(
                                              color: widget.index ==
                                                      fileNavigationProvider
                                                          .fileNavigationIndex
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ), //this.index = index),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => navigationButton();
}
