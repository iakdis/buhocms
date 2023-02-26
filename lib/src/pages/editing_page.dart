import 'dart:io';

import 'package:buhocms/src/provider/navigation/file_navigation_provider.dart';
import 'package:buhocms/src/ssg/hugo.dart';
import 'package:buhocms/src/utils/globals.dart';
import 'package:buhocms/src/widgets/editing_page/tabs.dart';
import '../logic/buho_functions.dart';
import '../ssg/add_frontmatter.dart';
import '../widgets/markdown/markdown_viewer.dart';
import 'package:flutter/material.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../logic/files.dart';
import '../provider/editing/editing_provider.dart';
import '../provider/navigation/navigation_size_provider.dart';
import '../provider/editing/unsaved_text_provider.dart';
import '../utils/preferences.dart';
import '../utils/unsaved_check.dart';
import '../widgets/tooltip.dart';

class EditingPage extends StatefulWidget {
  const EditingPage({
    super.key,
    required this.isGUIMode,
    required this.editingPageKey,
    required this.focusNodePage,
  });

  final bool isGUIMode;
  final GlobalKey<EditingPageState> editingPageKey;
  final FocusNode focusNodePage;

  @override
  State<EditingPage> createState() => EditingPageState();
}

class EditingPageState extends State<EditingPage> with WindowListener {
  late final FocusNode focusNodeTextField;
  List<HugoWidget> hugoWidgets = [];
  List<GlobalKey<HugoWidgetState>> globalKey = [];
  bool frontmatterVisible = true;
  bool editTextVisible = true;
  bool draggableFrontMatter = false;
  late final EditingProvider editingProvider;
  late final FileNavigationProvider fileNavigationProvider;
  late final UnsavedTextProvider unsavedTextProvider;
  late final NavigationSizeProvider navigationSizeProvider;

  @override
  void initState() {
    windowManager.addListener(this);

    //getAllFilesFuture = getAllFiles(context: context);
    editingProvider = Provider.of<EditingProvider>(context, listen: false);
    fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);
    unsavedTextProvider =
        Provider.of<UnsavedTextProvider>(context, listen: false);
    navigationSizeProvider =
        Provider.of<NavigationSizeProvider>(context, listen: false);

    focusNodeTextField = FocusNode();

    addListenerController();

    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    fileNavigationProvider.controller.removeListener(addListenerContent);
    focusNodeTextField.dispose();

    super.dispose();
  }

  void addListenerController() async {
    await fileNavigationProvider.setInitialTexts();

    updateTexts();

    unsavedTextProvider
        .setSavedText(fileNavigationProvider.markdownTextContent);
    unsavedTextProvider
        .setUnsavedText(fileNavigationProvider.markdownTextContent);
    unsavedTextProvider
        .setSavedTextFrontmatter(fileNavigationProvider.frontMatterText);
    unsavedTextProvider
        .setUnsavedTextFrontmatter(fileNavigationProvider.frontMatterText);

    editingProvider
        .setMarkdownViewerText(fileNavigationProvider.controller.text);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        fileNavigationProvider.controller.addListener(addListenerContent);
        fileNavigationProvider.controllerFrontmatter
            .addListener(addListenerContentFrontmatter);
      },
    );

    updateHugoWidgets();
  }

  Future<void> updateHugoWidgets() async {
    print('Hugo widgets update!');

    await fileNavigationProvider.setInitialTexts();

    var frontMatterText = '---\n---';
    if (fileNavigationProvider.initialText.isNotEmpty &&
        fileNavigationProvider.initialText.contains('---', 1)) {
      frontMatterText = fileNavigationProvider.initialText.substring(
          0, fileNavigationProvider.initialText.indexOf('---', 1) + 3);
    }
    fileNavigationProvider.setFrontMatterText(frontMatterText.trim());

    final baseOffset = fileNavigationProvider.controller.selection.baseOffset;
    final extentOffset =
        fileNavigationProvider.controller.selection.extentOffset;

    editingProvider.isGUIMode
        ? fileNavigationProvider.controller.text =
            fileNavigationProvider.markdownTextContent
        : fileNavigationProvider.controller.text =
            '${fileNavigationProvider.frontMatterText}\n\n${fileNavigationProvider.markdownTextContent}';
    fileNavigationProvider.controllerFrontmatter.text =
        fileNavigationProvider.frontMatterText;
    unsavedTextProvider
        .setSavedText(fileNavigationProvider.markdownTextContent);
    unsavedTextProvider
        .setUnsavedText(fileNavigationProvider.markdownTextContent);
    unsavedTextProvider
        .setSavedTextFrontmatter(fileNavigationProvider.frontMatterText);
    unsavedTextProvider
        .setUnsavedTextFrontmatter(fileNavigationProvider.frontMatterText);

    final textLength = fileNavigationProvider.controller.text.length;
    fileNavigationProvider.controller.selection = TextSelection(
        baseOffset: textLength >= baseOffset ? baseOffset : 0,
        extentOffset: textLength >= extentOffset ? extentOffset : 0);

    var finalLines = <String>[];
    var frontMatterLines = fileNavigationProvider.frontMatterText.split('\n');
    print('HERE: ${frontMatterLines.length}');
    for (var i = 0; i < frontMatterLines.length; i++) {
      if (frontMatterLines[i].isNotEmpty) {
        finalLines.add(frontMatterLines[i]);
      }
    }

    globalKey = [];
    hugoWidgets = [];
    if (finalLines.isEmpty) return;
    if (finalLines[0].isEmpty) return;
    finalLines
      ..removeAt(0)
      ..removeAt(finalLines.length - 1);

    for (var index = 0; index < finalLines.length; index++) {
      globalKey.add(GlobalKey<HugoWidgetState>());

      hugoWidgets.add(HugoWidget(
        source: finalLines[index],
        index: index,
        setStateCallback: saveFileAndFrontmatter,
        key: globalKey[index],
        editingPageKey: widget.editingPageKey,
      ));
    }
  }

  void addListenerContent() {
    updateTexts();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        editingProvider
            .setMarkdownViewerText(fileNavigationProvider.controller.text);
        unsavedTextProvider
            .setUnsavedText(fileNavigationProvider.markdownTextContent);
      },
    );
  }

  void addListenerContentFrontmatter() {
    fileNavigationProvider
        .setFrontMatterText(fileNavigationProvider.controllerFrontmatter.text);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        unsavedTextProvider
            .setUnsavedTextFrontmatter(fileNavigationProvider.frontMatterText);
      },
    );
  }

  void updateTexts() {
    if (editingProvider.isGUIMode) {
      fileNavigationProvider
          .setMarkdownTextContent(fileNavigationProvider.controller.text);
    } else {
      var frontMatterText = '---\n---';
      if (fileNavigationProvider.controller.text.isNotEmpty &&
          fileNavigationProvider.controller.text.contains('---', 1)) {
        frontMatterText = fileNavigationProvider.controller.text.substring(
            0, fileNavigationProvider.controller.text.indexOf('---', 1) + 3);
      }
      fileNavigationProvider.setFrontMatterText(frontMatterText.trim());
      fileNavigationProvider.setMarkdownTextContent(
          fileNavigationProvider.controller.text.trim());
    }
  }

  Future<void> checkUnsavedCustomFunction({
    required Function() function,
    required bool checkUnsaved,
  }) async {
    if (checkUnsaved) {
      if (unsavedTextProvider.unsaved(globalKey: globalKey)) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.unsavedChanges),
            content:
                Text(AppLocalizations.of(context)!.unsavedChanges_Description),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () async {
                  await revertFileAndFrontmatter();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  function();
                },
                child: Text(AppLocalizations.of(context)!.revert),
              ),
              TextButton(
                onPressed: () async {
                  await saveFileAndFrontmatter();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  function();
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        );
        return;
      } else {
        function();
        return;
      }
    }
    print('FUNCTION()');

    function();
  }

  Future<void> revertFileAndFrontmatter() async {
    for (var i = 0; i < globalKey.length; i++) {
      globalKey[i].currentState?.restore();
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
    unsavedTextProvider
        .setSavedText(fileNavigationProvider.markdownTextContent);
    fileNavigationProvider.controllerFrontmatter.text =
        fileNavigationProvider.frontMatterText;
    unsavedTextProvider
        .setSavedTextFrontmatter(fileNavigationProvider.frontMatterText);

    setState(() {});
  }

  Future<void> saveFileAndFrontmatter() async {
    for (var i = 0; i < globalKey.length; i++) {
      globalKey[i].currentState?.save();
    }
    await saveFile(context);

    unsavedTextProvider
        .setSavedText(fileNavigationProvider.markdownTextContent);
    unsavedTextProvider
        .setSavedTextFrontmatter(fileNavigationProvider.frontMatterText);

    widget.editingPageKey.currentState?.updateHugoWidgets();
  }

  Widget showHideArea({
    required String title,
    required Function setVisible,
    required bool visible,
  }) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: [
        SelectableText(
          title,
          style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        TextButton.icon(
          onPressed: () {
            checkUnsavedBeforeFunction(
                editingPageKey: widget.editingPageKey,
                function: () => setState(() => setVisible()));
          },
          label: Text(visible
              ? AppLocalizations.of(context)!.hide
              : AppLocalizations.of(context)!.show),
          icon: Icon(
            visible ? Icons.expand_less : Icons.expand_more,
          ),
        ),
      ],
    );
  }

  Widget draggableFrontmatterButton() {
    return CustomTooltip(
      message: AppLocalizations.of(context)!.draggableMode_Description,
      child: ElevatedButton.icon(
        onPressed: () {
          checkUnsavedBeforeFunction(
              editingPageKey: widget.editingPageKey,
              function: () =>
                  setState(() => draggableFrontMatter = !draggableFrontMatter));
        },
        icon: Icon(
            draggableFrontMatter ? Icons.lock_outline : Icons.drag_indicator),
        label: Text(draggableFrontMatter
            ? AppLocalizations.of(context)!.draggableModeLock
            : AppLocalizations.of(context)!.draggableModeOn),
      ),
    );
  }

  Widget textFrontmatterButton() {
    return CustomTooltip(
      message: editingProvider.isFrontmatterGUIMode
          ? AppLocalizations.of(context)!.textMode
          : AppLocalizations.of(context)!.guiMode,
      child: ElevatedButton.icon(
        onPressed: () {
          checkUnsavedBeforeFunction(
              editingPageKey: widget.editingPageKey,
              function: () => setState(() =>
                  editingProvider.setFrontmatterGUIMode(
                      !editingProvider.isFrontmatterGUIMode)));
        },
        icon: Icon(editingProvider.isFrontmatterGUIMode
            ? Icons.text_snippet_outlined
            : Icons.table_chart),
        label: Text(editingProvider.isFrontmatterGUIMode
            ? AppLocalizations.of(context)!.textMode
            : AppLocalizations.of(context)!.guiMode),
      ),
    );
  }

  Widget guiFrontmatter({required List<String> finalLines}) {
    return Consumer<UnsavedTextProvider>(builder: (_, __, ___) {
      return ReorderableListView(
        shrinkWrap: true,
        buildDefaultDragHandles: false,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;

          final finalLine = finalLines.removeAt(oldIndex);
          finalLines.insert(newIndex, finalLine);
          var newLines = [for (var v in finalLines) v];
          newLines.insert(0, '---');
          newLines.insert(finalLines.length + 1, '---');
          var newFinalLines = newLines.join('\n');

          fileNavigationProvider.setFrontMatterText(newFinalLines);

          final oldHugoWidget = hugoWidgets.removeAt(oldIndex);
          hugoWidgets.insert(newIndex, oldHugoWidget);

          saveFileAndFrontmatter();
        },
        onReorderStart: (index) {
          checkUnsavedBeforeFunction(
              editingPageKey: widget.editingPageKey, function: () {});
        },
        children: [
          for (var index = 0; index < hugoWidgets.length; index++)
            Column(
              key: ValueKey(index),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16.0,
                  children: [
                    if (draggableFrontMatter)
                      SizedBox(
                        //width: 64,
                        child: ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.drag_handle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    hugoWidgets[index],
                  ],
                ),
                const Divider(),
              ],
            )
        ],
      );
    });
  }

  Widget textFrontmatter() {
    return Consumer<FileNavigationProvider>(
      builder: (context, value, _) {
        return TextField(
          controller: value.controllerFrontmatter,
          minLines: 5,
          maxLines: null,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.frontmatter,
            labelText: AppLocalizations.of(context)!.frontmatter,
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  Widget guiFrontMatterAndTextEditor({required List<String> finalLines}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showHideArea(
          title: AppLocalizations.of(context)!.content,
          setVisible: () => editTextVisible = !editTextVisible,
          visible: editTextVisible,
        ),
        const SizedBox(height: 16),
        if (editTextVisible) guiTextEditor(),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 16),
        showHideArea(
          title: AppLocalizations.of(context)!.frontmatter,
          setVisible: () => frontmatterVisible = !frontmatterVisible,
          visible: frontmatterVisible,
        ),
        const SizedBox(height: 16),
        if (frontmatterVisible)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 64.0,
                runSpacing: 8.0,
                children: [
                  AddFrontmatterButton(editingPageKey: widget.editingPageKey),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      textFrontmatterButton(),
                      draggableFrontmatterButton(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 16.0),
              editingProvider.isFrontmatterGUIMode
                  ? guiFrontmatter(finalLines: finalLines)
                  : textFrontmatter(),
            ],
          ),
      ],
    );
  }

  Widget guiTextEditor({bool showMarkdownViewer = true}) {
    var windowWidth = MediaQuery.of(context).size.width;
    var navigationSize = navigationSizeProvider.navigationWidth;
    var fileNavigationSize = navigationSizeProvider.fileNavigationWidth;
    var editingPageSize = windowWidth - (navigationSize + fileNavigationSize);

    return Consumer<UnsavedTextProvider>(
      builder: (_, unsavedTextProvider, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (unsavedTextProvider.savedText !=
                    unsavedTextProvider.unsavedText ||
                unsavedTextProvider.savedTextFrontmatter !=
                    unsavedTextProvider.unsavedTextFrontmatter)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('*', style: TextStyle(fontSize: 24)),
              ),
            Consumer<FileNavigationProvider>(
              builder: (context, value, _) {
                return MarkdownToolbar(
                  useIncludedTextField: false,
                  controller: value.controller,
                  focusNode: focusNodeTextField,
                  flipCollapseButtonIcon: true,
                  width: 45,
                  height: 30,
                  iconSize: 22,
                  collapsable: true,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  iconColor: Theme.of(context).colorScheme.onPrimary,
                  dropdownTextColor: Theme.of(context).colorScheme.primary,
                );
              },
            ),
            const SizedBox(height: 8.0),
            editingPageSize > 900
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _textEditor()),
                      if (showMarkdownViewer)
                        Expanded(child: _markdownViewer()),
                    ],
                  )
                : Column(
                    children: [
                      _textEditor(),
                      if (showMarkdownViewer) _markdownViewer(),
                    ],
                  ),
          ],
        );
      },
    );
  }

  Widget _textEditor() {
    return Consumer<FileNavigationProvider>(
      builder: (context, value, _) {
        return TextField(
          controller: value.controller,
          focusNode: focusNodeTextField,
          minLines: 5,
          maxLines: null,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.content_Description,
            labelText: AppLocalizations.of(context)!.content,
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  Widget _markdownViewer() {
    return const MarkdownViewer();
  }

  Widget _openInFolderButton({required String path}) {
    return TextButton.icon(
      onPressed: () =>
          openCurrentPathInFolder(path: path, keepPathTrailing: false),
      icon: const Icon(Icons.open_in_new),
      label: Text(path.substring(path.indexOf('content'))),
    );
  }

  void setTitle(UnsavedTextProvider unsavedTextProvider) {
    var title =
        '${(Preferences.getCurrentFile() ?? 'No file selected').split(Platform.pathSeparator).last} - BuhoCMS';
    var titleUnsaved = title;
    unsavedTextProvider.unsaved(globalKey: globalKey)
        ? titleUnsaved = '*$title'
        : titleUnsaved = title;
    windowManager.setTitle(titleUnsaved);
  }

  AppBar _appBar() {
    return AppBar(
      title: Consumer<UnsavedTextProvider>(
          builder: (context, unsavedTextProvider, _) {
        setTitle(unsavedTextProvider);

        return Row(
          children: [
            if (MediaQuery.of(context).size.width > mobileWidth)
              Row(
                children: [
                  const SizedBox(width: 16),
                  Text(AppLocalizations.of(context)!.editingPage),
                  const SizedBox(width: 8),
                ],
              ),
            Expanded(
              child: Tabs(
                editingPageKey: widget.editingPageKey,
                globalKey: globalKey,
                setStateCallback: () => setState(() {}),
              ), //https://github.com/flutter/flutter/issues/75180
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<FileNavigationProvider>(
        builder: (context, fileNavigationProvider, _) {
          return Focus(
            focusNode: widget.focusNodePage,
            autofocus: true,
            child: Scaffold(
              appBar: _appBar(),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () async {
                      revert(
                        context: context,
                        editingPageKey: widget.editingPageKey,
                        mounted: mounted,
                      );
                    },
                    tooltip: '${AppLocalizations.of(context)!.revert} [Ctrl+U]',
                    child: const Icon(Icons.restore),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () => save(
                        context: context,
                        editingPageKey: widget.editingPageKey),
                    tooltip: '${AppLocalizations.of(context)!.save} [Ctrl+S]',
                    child: const Icon(Icons.check),
                  ),
                ],
              ),
              body: FutureBuilder(
                future: getAllFiles(context: context),
                builder: (context, snapshot) {
                  print('UPDATE WIDGET HERE');

                  /*
                  TODO uncomment to test for double build
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }*/

                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      final directoryExists =
                          Directory(Preferences.getCurrentPath()).existsSync();
                      return Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(64.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SelectableText(
                                  directoryExists
                                      ? AppLocalizations.of(context)!
                                          .createYourFirstPost
                                      : AppLocalizations.of(context)!
                                          .error_DirectoryDoesNotExist(
                                              '"${Preferences.getCurrentPath()}"'),
                                  style: TextStyle(
                                    fontSize: 36.0,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                if (directoryExists)
                                  Column(
                                    children: [
                                      const SizedBox(height: 32.0),
                                      ElevatedButton.icon(
                                        onPressed: () => addFile(
                                            context: context,
                                            mounted: mounted,
                                            editingPageKey:
                                                widget.editingPageKey),
                                        icon: const Icon(Icons.text_snippet),
                                        label: Text(
                                            AppLocalizations.of(context)!
                                                .createNewPost),
                                        style: const ButtonStyle(
                                          fixedSize: MaterialStatePropertyAll(
                                              Size(double.infinity, 40.0)),
                                        ),
                                      ),
                                      const SizedBox(height: 24.0),
                                      ElevatedButton.icon(
                                        onPressed: () => addFolder(
                                            context: context,
                                            mounted: mounted,
                                            setStateCallback: () {},
                                            editingPageKey:
                                                widget.editingPageKey),
                                        icon: const Icon(Icons.folder_outlined),
                                        label: Text(
                                            AppLocalizations.of(context)!
                                                .createNewFolder),
                                        style: const ButtonStyle(
                                          fixedSize: MaterialStatePropertyAll(
                                              Size(double.infinity, 40.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (fileNavigationProvider.fileNavigationIndex == -1) {
                      return Center(
                        child: SelectableText(
                          AppLocalizations.of(context)!.noFileSelected,
                          style: TextStyle(
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    List<String> finalLines = [];

                    var frontMatterText = '---\n---';
                    if (fileNavigationProvider.initialText.isNotEmpty &&
                        fileNavigationProvider.initialText.contains('---', 1)) {
                      frontMatterText = fileNavigationProvider.initialText
                          .substring(
                              0,
                              fileNavigationProvider.initialText
                                      .indexOf('---', 1) +
                                  3);
                    }
                    fileNavigationProvider
                        .setFrontMatterText(frontMatterText.trim());
                    var frontMatterLines =
                        fileNavigationProvider.frontMatterText.split('\n');
                    print('HERE: ${frontMatterLines.length}');
                    for (var i = 0; i < frontMatterLines.length; i++) {
                      if (frontMatterLines[i].isNotEmpty) {
                        finalLines.add(frontMatterLines[i]);
                      }
                    }

                    if (finalLines.isNotEmpty) {
                      if (finalLines[0].isNotEmpty) {
                        finalLines
                          ..removeAt(0)
                          ..removeAt(finalLines.length - 1);
                      }
                    }

                    var path = '';
                    var title = '';
                    if (snapshot.data!.isNotEmpty) {
                      path = snapshot
                          .data![fileNavigationProvider.fileNavigationIndex]
                          .path;
                      title = path.split(Platform.pathSeparator).last;
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: constraints.maxWidth > mobileWidth
                            ? const EdgeInsets.all(32.0)
                            : const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 64.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SelectableText(
                              snapshot.data != null
                                  ? title.substring(0, title.length - 3)
                                  : 'No snapshot data',
                              style: TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(height: 8.0),
                            _openInFolderButton(path: path),
                            const SizedBox(height: 46.0),
                            widget.isGUIMode
                                ? guiFrontMatterAndTextEditor(
                                    finalLines: finalLines,
                                  )
                                : SizedBox(
                                    child: guiTextEditor(
                                        showMarkdownViewer: false),
                                  ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          );
        },
      );
    });
  }
}
