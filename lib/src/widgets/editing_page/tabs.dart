import 'dart:io';

import 'package:buhocms/src/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pages/editing_page.dart';
import '../../provider/navigation/file_navigation_provider.dart';
import '../../provider/editing/tabs_provider.dart';
import '../../provider/editing/unsaved_text_provider.dart';
import '../../ssg/hugo.dart';
import '../../utils/preferences.dart';
import '../../utils/unsaved_check.dart';

class Tabs extends StatefulWidget {
  const Tabs({
    super.key,
    required this.editingPageKey,
    required this.globalKey,
    required this.setStateCallback,
  });

  final GlobalKey<EditingPageState> editingPageKey;
  final List<GlobalKey<HugoWidgetState>> globalKey;
  final Function setStateCallback;

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  List<MapEntry<String, int>> tabs = [];

  @override
  void initState() {
    final tabsProvider = Provider.of<TabsProvider>(context, listen: false);

    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
        tabsProvider.scrollToTab(
            fileNavigationIndex: fileNavigationProvider.fileNavigationIndex));

    super.initState();
  }

  Widget _tabs() {
    return Consumer<TabsProvider>(builder: (_, tabsProvider, __) {
      tabs = tabsProvider.tabs;
      tabsProvider.setGlobalKeys([
        for (var i = 0; i < tabs.length; i++) GlobalKey(),
      ]);
      List<Tab> tabsWidget = tabs.asMap().entries.map(
        (e) {
          return Tab(
            key: tabsProvider.globalKeys[e.key],
            editingPageKey: widget.editingPageKey,
            globalKey: widget.globalKey,
            setStateCallback: widget.setStateCallback,
            index: e.key,
            title: e.value.key,
            fileIndex: e.value.value,
          );
        },
      ).toList();

      return Scrollbar(
        controller: tabsProvider.scrollController,
        thumbVisibility: true,
        child: SizedBox(
          height: 50,
          child: ReorderableListView(
            scrollController: tabsProvider.scrollController,
            scrollDirection: Axis.horizontal,
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) => child,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;

              var tabs = tabsProvider.tabs;
              final tab = tabs.removeAt(oldIndex);
              tabs.insert(newIndex, tab);
              tabsProvider.setTabs(tabs);
            },
            onReorderStart: (index) {
              checkUnsavedBeforeFunction(
                  editingPageKey: widget.editingPageKey, function: () {});
            },
            children: [
              for (var index = 0; index < tabs.length; index++)
                Container(
                  key: ValueKey(tabsWidget[index]),
                  child: tabsWidget[index],
                ),
            ],
          ),
        ), //https://github.com/flutter/flutter/issues/75180
      );
    });
  }

  @override
  Widget build(BuildContext context) => _tabs();
}

class Tab extends StatefulWidget {
  const Tab({
    Key? key,
    required this.editingPageKey,
    required this.globalKey,
    required this.setStateCallback,
    required this.index,
    required this.title,
    required this.fileIndex,
  }) : super(key: key);

  final GlobalKey<EditingPageState> editingPageKey;
  final List<GlobalKey<HugoWidgetState>> globalKey;
  final Function setStateCallback;
  final int index;
  final String title;
  final int fileIndex;

  @override
  _TabState createState() => _TabState();
}

class _TabState extends State<Tab> {
  bool hovering = false;

  void _removeTab() {
    checkUnsavedBeforeFunction(
      editingPageKey: widget.editingPageKey,
      function: () {
        final tabsProvider = Provider.of<TabsProvider>(context, listen: false);
        tabsProvider.removeTab(widget.index);

        final fileNavigationProvider =
            Provider.of<FileNavigationProvider>(context, listen: false);
        if (widget.fileIndex == fileNavigationProvider.fileNavigationIndex) {
          fileNavigationProvider.setFileNavigationIndex(-1);
        }
      },
    );
  }

  Widget _tab() {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);
    final unsavedTextProvider =
        Provider.of<UnsavedTextProvider>(context, listen: false);

    return CustomTooltip(
      message: widget.title.substring(widget.title.indexOf('content')),
      child: ReorderableDragStartListener(
        index: widget.index,
        child: GestureDetector(
          onTertiaryTapUp: (details) => _removeTab(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onHover: (value) {
                setState(() {
                  hovering = value;
                });
              },
              onTap:
                  widget.fileIndex == fileNavigationProvider.fileNavigationIndex
                      ? () {}
                      : () async {
                          checkUnsavedBeforeFunction(
                            editingPageKey: widget.editingPageKey,
                            function: () async {
                              fileNavigationProvider
                                  .setFileNavigationIndex(widget.fileIndex);

                              await Preferences.setCurrentFile(widget.title);
                              await fileNavigationProvider.setInitialTexts();

                              widget.editingPageKey.currentState
                                  ?.updateHugoWidgets();
                            },
                          );
                          print(
                              'Clicked tab ${widget.index}, file: ${widget.fileIndex}');
                        },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 8),
                  if (unsavedTextProvider.unsaved(
                          globalKey: widget.globalKey) &&
                      widget.fileIndex ==
                          fileNavigationProvider.fileNavigationIndex)
                    Text('* ',
                        style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.onPrimary)),
                  SizedBox(
                    width: 140,
                    child: Text(
                      widget.title
                          .substring(0, widget.title.length - 3)
                          .split(Platform.pathSeparator)
                          .last
                          .replaceAll('', '\u{200B}'),
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle(
                        color: widget.fileIndex ==
                                fileNavigationProvider.fileNavigationIndex
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.secondaryContainer,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  hovering ||
                          widget.fileIndex ==
                              fileNavigationProvider.fileNavigationIndex
                      ? IconButton(
                          splashRadius: 12,
                          constraints: const BoxConstraints(minHeight: 48),
                          onPressed: () => _removeTab(),
                          icon: Icon(
                            Icons.close,
                            color: widget.fileIndex !=
                                        fileNavigationProvider
                                            .fileNavigationIndex &&
                                    hovering
                                ? Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                : null,
                          ),
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                        )
                      : const SizedBox(width: 16, height: 16),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _tab();
}
