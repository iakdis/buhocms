import 'dart:io';

import 'package:buhocms/src/provider/navigation/file_navigation_provider.dart';
import 'package:buhocms/src/ssg/hugo.dart';
import 'package:buhocms/src/utils/globals.dart';
import 'package:buhocms/src/widgets/editing_page/tabs.dart';
import '../i18n/l10n.dart';
import '../logic/buho_functions.dart';
import '../ssg/add_frontmatter.dart';
import '../widgets/markdown/markdown_viewer.dart';
import 'package:flutter/material.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

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
    required this.focusNodePage,
  });

  final bool isGUIMode;
  final FocusNode focusNodePage;

  @override
  State<EditingPage> createState() => EditingPageState();
}

class EditingPageState extends State<EditingPage> with WindowListener {
  late final FocusNode focusNodeTextField;
  List<FrontmatterWidget> hugoWidgets = [];
  List<GlobalKey<FrontmatterWidgetState>> globalKey = [];
  bool frontmatterVisible = true;
  bool editTextVisible = true;
  bool draggableFrontMatter = false;
  late final EditingProvider editingProvider;
  late final FileNavigationProvider fileNavigationProvider;
  late final UnsavedTextProvider unsavedTextProvider;
  late final NavigationSizeProvider navigationSizeProvider;
  static const double textFieldMinHeight = 100.0;
  Color? textFieldHandleColor;
  GlobalKey textFieldKey = GlobalKey();

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

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        fileNavigationProvider.controller.addListener(addListenerContent);
        fileNavigationProvider.controllerFrontmatter
            .addListener(addListenerContentFrontmatter);
      },
    );

    await updateHugoWidgets();

    editingProvider
        .setMarkdownViewerText(fileNavigationProvider.controller.text);
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
      globalKey.add(GlobalKey<FrontmatterWidgetState>());

      hugoWidgets.add(FrontmatterWidget(
        source: finalLines[index],
        index: index,
        setStateCallback: saveFileAndFrontmatter,
        key: globalKey[index],
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
            title: Text(Localization.appLocalizations().unsavedChanges),
            content: Text(
                Localization.appLocalizations().unsavedChanges_Description),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(Localization.appLocalizations().cancel),
              ),
              TextButton(
                onPressed: () async {
                  await revertFileAndFrontmatter();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  function();
                },
                child: Text(Localization.appLocalizations().revert),
              ),
              TextButton(
                onPressed: () async {
                  await saveFileAndFrontmatter();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  function();
                },
                child: Text(Localization.appLocalizations().save),
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
    final editingPageKey = context.read<EditingProvider>().editingPageKey;
    for (var i = 0; i < globalKey.length; i++) {
      globalKey[i].currentState?.save();
    }
    await saveFile(context);

    unsavedTextProvider
        .setSavedText(fileNavigationProvider.markdownTextContent);
    unsavedTextProvider
        .setSavedTextFrontmatter(fileNavigationProvider.frontMatterText);

    editingPageKey.currentState?.updateHugoWidgets();
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
          style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: () {
            checkUnsavedBeforeFunction(
                context: context, function: () => setState(() => setVisible()));
          },
          label: Text(
            visible
                ? Localization.appLocalizations().hide
                : Localization.appLocalizations().show,
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
          icon: Icon(
            visible ? Icons.expand_less : Icons.expand_more,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget draggableFrontmatterButton() {
    return CustomTooltip(
      message: Localization.appLocalizations().draggableMode_Description,
      child: ElevatedButton.icon(
        onPressed: () {
          checkUnsavedBeforeFunction(
              context: context,
              function: () =>
                  setState(() => draggableFrontMatter = !draggableFrontMatter));
        },
        icon: Icon(
            draggableFrontMatter ? Icons.lock_outline : Icons.drag_indicator),
        label: Text(draggableFrontMatter
            ? Localization.appLocalizations().draggableModeLock
            : Localization.appLocalizations().draggableModeOn),
      ),
    );
  }

  Widget textFrontmatterButton() {
    return CustomTooltip(
      message: editingProvider.isFrontmatterGUIMode
          ? Localization.appLocalizations().textMode
          : Localization.appLocalizations().guiMode,
      child: ElevatedButton.icon(
        onPressed: () {
          checkUnsavedBeforeFunction(
              context: context,
              function: () => setState(() =>
                  editingProvider.setFrontmatterGUIMode(
                      !editingProvider.isFrontmatterGUIMode)));
        },
        icon: Icon(editingProvider.isFrontmatterGUIMode
            ? Icons.text_snippet_outlined
            : Icons.table_chart),
        label: Text(editingProvider.isFrontmatterGUIMode
            ? Localization.appLocalizations().textMode
            : Localization.appLocalizations().guiMode),
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
          checkUnsavedBeforeFunction(context: context, function: () {});
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
                          child: const Icon(Icons.drag_handle),
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
            hintText: Localization.appLocalizations().frontmatter,
            labelText: Localization.appLocalizations().frontmatter,
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
          title: Localization.appLocalizations().content,
          setVisible: () => editTextVisible = !editTextVisible,
          visible: editTextVisible,
        ),
        const SizedBox(height: 16),
        if (editTextVisible) guiTextEditor(),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 16),
        showHideArea(
          title: Localization.appLocalizations().frontmatter,
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
                  const AddFrontmatterButton(),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      if (editingProvider.isFrontmatterGUIMode)
                        draggableFrontmatterButton(),
                      textFrontmatterButton(),
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
                  key: context.watch<EditingProvider>().markdownToolbarKey,
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
                  headingTooltip:
                      Localization.appLocalizations().tooltipHeading,
                  boldTooltip:
                      '${Localization.appLocalizations().tooltipBold} [Ctrl+B]',
                  italicTooltip:
                      '${Localization.appLocalizations().tooltipItalic} [Ctrl+I]',
                  strikethroughTooltip:
                      Localization.appLocalizations().tooltipStrikethrough,
                  linkTooltip:
                      '${Localization.appLocalizations().tooltipLink} [Ctrl+K]',
                  imageTooltip:
                      '${Localization.appLocalizations().tooltipImage} [Ctrl+P]',
                  codeTooltip:
                      '${Localization.appLocalizations().tooltipCode} [Ctrl+E]',
                  bulletedListTooltip:
                      '${Localization.appLocalizations().tooltipBulletedList} [Ctrl+Shift+8]',
                  numberedListTooltip:
                      '${Localization.appLocalizations().tooltipNumberedList} [Ctrl+Shift+7]',
                  checkboxTooltip:
                      Localization.appLocalizations().tooltipCheckbox,
                  quoteTooltip:
                      '${Localization.appLocalizations().tooltipQuote} [Ctrl+.]',
                  horizontalRuleTooltip:
                      '${Localization.appLocalizations().tooltipHorizontalRule} [Ctrl+Shift+H]',
                );
              },
            ),
            const SizedBox(height: 8.0),
            editingPageSize > 900
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _textEditor()),
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

  void _setActiveHandleColor() => setState(
      () => textFieldHandleColor = Theme.of(context).colorScheme.primary);

  void _resetActiveHandleColor() => setState(() =>
      textFieldHandleColor = Theme.of(context).disabledColor.withAlpha(64));

  Widget _textEditor() {
    return Consumer<FileNavigationProvider>(
      builder: (context, value, _) {
        return Column(
          children: [
            SizedBox(
              height: value.textFieldHeight,
              child: TextField(
                key: textFieldKey,
                controller: value.controller,
                focusNode: focusNodeTextField,
                expands: value.textFieldHeight != null ? true : false,
                minLines: value.textFieldHeight != null ? null : 5,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: Localization.appLocalizations().content_Description,
                  labelText: Localization.appLocalizations().content,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              height: 30,
              width: 60,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                onEnter: (event) => _setActiveHandleColor(),
                onExit: (event) => _resetActiveHandleColor(),
                child: GestureDetector(
                  child: Transform.scale(
                    scale: 3,
                    child: Icon(
                      Icons.horizontal_rule_rounded,
                      size: 30,
                      color: textFieldHandleColor ??
                          Theme.of(context).disabledColor.withAlpha(64),
                    ),
                  ),
                  onPanUpdate: (details) {
                    var textFieldSize = textFieldMinHeight;
                    if (textFieldKey.currentContext != null) {
                      final renderBox = textFieldKey.currentContext!
                          .findRenderObject() as RenderBox;
                      textFieldSize = renderBox.size.height;
                    }

                    setState(() {
                      final newHeight =
                          (value.textFieldHeight ?? textFieldSize) +
                              details.delta.dy;
                      value.setTextFieldHeight(newHeight);

                      if ((value.textFieldHeight ?? 0) < textFieldMinHeight) {
                        value.setTextFieldHeight(textFieldMinHeight);
                      }
                    });

                    _setActiveHandleColor();
                  },
                  onPanEnd: (details) => _resetActiveHandleColor(),
                ),
              ),
            ),
          ],
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
      icon: Icon(
        Icons.open_in_new,
        color: Theme.of(context).colorScheme.onBackground,
      ),
      label: Text(
        path.substring(path.indexOf('content')),
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }

  void setTitle() {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);
    final unsavedTextProvider =
        Provider.of<UnsavedTextProvider>(context, listen: false);

    final fileName = fileNavigationProvider.fileNavigationIndex == -1
        ? 'No file selected'
        : Preferences.getCurrentFile()?.split(Platform.pathSeparator).last ??
            'No file selected';
    final title = '$fileName - BuhoCMS';

    final finalTitle =
        unsavedTextProvider.unsaved(globalKey: globalKey) ? '*$title' : title;

    windowManager.setTitle(finalTitle);
  }

  AppBar _appBar() {
    return AppBar(
      title: Consumer2<UnsavedTextProvider, FileNavigationProvider>(
          builder: (context, _, __, ___) {
        setTitle();

        return Row(
          children: [
            if (MediaQuery.of(context).size.width > mobileWidth)
              Row(
                children: [
                  const SizedBox(width: 16),
                  Text(Localization.appLocalizations().editingPage),
                  const SizedBox(width: 8),
                ],
              ),
            Expanded(
              child: Tabs(
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
                        mounted: mounted,
                      );
                    },
                    tooltip:
                        '${Localization.appLocalizations().revert} [Ctrl+U]',
                    child: const Icon(Icons.restore),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () => save(context: context),
                    tooltip: '${Localization.appLocalizations().save} [Ctrl+S]',
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
                                      ? Localization.appLocalizations()
                                          .createYourFirstPost
                                      : Localization.appLocalizations()
                                          .error_DirectoryDoesNotExist(
                                              '"${Preferences.getCurrentPath()}"'),
                                  style: const TextStyle(
                                    fontSize: 36.0,
                                    fontWeight: FontWeight.bold,
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
                                        ),
                                        icon: const Icon(Icons.text_snippet),
                                        label: Text(
                                            Localization.appLocalizations()
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
                                        ),
                                        icon: const Icon(Icons.folder_outlined),
                                        label: Text(
                                            Localization.appLocalizations()
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
                          Localization.appLocalizations().noFileSelected,
                          style: const TextStyle(
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
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
                            ? const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 256.0)
                            : const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 64.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SelectableText(
                              snapshot.data != null
                                  ? title.substring(0, title.length - 3)
                                  : 'No snapshot data',
                              style: const TextStyle(
                                fontSize: 32.0,
                                fontWeight: FontWeight.bold,
                              ),
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
