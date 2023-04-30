import 'dart:io';

import 'package:buhocms/src/logic/buho_functions.dart';
import 'package:buhocms/src/provider/navigation/file_navigation_provider.dart';
import 'package:buhocms/src/provider/navigation/navigation_provider.dart';
import 'package:buhocms/src/provider/navigation/navigation_size_provider.dart';
import 'package:buhocms/src/widgets/file_navigation/buttons/create_new_button.dart';
import 'package:buhocms/src/widgets/file_navigation/buttons/directory_button.dart';
import 'package:buhocms/src/widgets/file_navigation/buttons/file_button.dart';
import 'package:buhocms/src/widgets/file_navigation/buttons/parent_folder_button.dart';
import 'package:buhocms/src/widgets/file_navigation/buttons/sort_button.dart';
import 'package:buhocms/src/widgets/resize_bar.dart';
import 'package:buhocms/src/widgets/tooltip.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/l10n.dart';
import '../../logic/files.dart';
import '../../ssg/ssg.dart';
import '../../utils/globals.dart';
import '../../utils/preferences.dart';
import 'context_menus/add_folder.dart';

class FilesNavigationDrawer extends StatefulWidget {
  const FilesNavigationDrawer({super.key});

  @override
  State<FilesNavigationDrawer> createState() => _FilesNavigationDrawerState();
}

class _FilesNavigationDrawerState extends State<FilesNavigationDrawer>
    with WidgetsBindingObserver {
  final ScrollController _listScrollController = ScrollController();
  Map<String, int> fileButtonsMap = {};

  double lastWidth = 64;

  double top = 0;
  double left = 0;

  final TextStyle textStyle = const TextStyle(fontSize: 16);

  @override
  void initState() {
    final navigationSizeProvider =
        Provider.of<NavigationSizeProvider>(context, listen: false);
    navigationSizeProvider.setFileNavigationWidth(
      Preferences.getFileNavigationSize(),
      notify: false,
    );
    lastWidth = Preferences.getFileNavigationSize();
    navigationSizeProvider.setIsExtendedFileNav(
      navigationSizeProvider.fileNavigationWidth > 64 ? true : false,
      notify: false,
    );

    super.initState();
  }

  Widget _expandButton() {
    final navigationSizeProvider =
        Provider.of<NavigationSizeProvider>(context, listen: false);
    return Align(
      alignment: navigationSizeProvider.isExtendedFileNav
          ? Alignment.centerRight
          : Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          child: RotatedBox(
            quarterTurns: 3,
            child: Icon(
              navigationSizeProvider.isExtendedFileNav
                  ? Icons.expand_less
                  : Icons.expand_more,
              size: 48.0,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          onTap: () => setState(() {
            if (navigationSizeProvider.isExtendedFileNav) {
              navigationSizeProvider.setIsExtendedFileNav(false);
              navigationSizeProvider.setFileNavigationWidth(64);
            } else {
              navigationSizeProvider.setIsExtendedFileNav(true);
              navigationSizeProvider
                  .setFileNavigationWidth(lastWidth > 200 ? lastWidth : 200);
            }
            Preferences.setFileNavigationSize(
                navigationSizeProvider.fileNavigationWidth);
          }),
        ),
      ),
    );
  }

  void setStateCallback() => setState(() {});

  Widget _listFilesAndDirectories(
      NavigationSizeProvider navigationSizeProvider) {
    print(Preferences.getCurrentPath());
    var savePath = Preferences.getCurrentPath();
    fileButtonsMap.clear();
    return FutureBuilder(
      future: getAllFilesAndDirectoriesInDirectory(
          path: savePath, recursive: false),
      builder: (context, snapshot) {
        return FutureBuilder(
          future: getAllFiles(),
          builder: (context, snapshotAllFiles) {
            return ListView.builder(
              shrinkWrap: true,
              /*separatorBuilder: (context, index) {
          return Divider(color: Theme.of(context).colorScheme.onSecondary);
        },*/
              itemCount: snapshot.data?.length ?? 0,
              //itemCount: files.length,
              //itemCount: folderCount,
              itemBuilder: (BuildContext context, int index) {
                if (snapshot.data?[index] is Directory) {
                  return Material(
                    key: UniqueKey(),
                    color: Colors.transparent,
                    child: DirectoryButton(
                      buttonText:
                          '${snapshot.data?[index].path.split(Platform.pathSeparator).last}',
                      index: index,
                      path: snapshot.data?[index].path ?? 'No file path found',
                      isExtended: navigationSizeProvider.isExtendedFileNav,
                      setStateCallback: setStateCallback,
                      insideFolder: false,
                    ),
                  );
                } else if (snapshot.data?[index] is File) {
                  fileButtonsMap.addEntries([
                    MapEntry(
                        snapshot.data?[index].path ?? 'Unknown path', index)
                  ]);
                  //print('Entries: $fileButtonsMap');
                  var allFiles = snapshotAllFiles.data ?? [];
                  var finalIndex = index;
                  for (var i = 0; i < allFiles.length; i++) {
                    if (allFiles[i].path == snapshot.data?[index].path) {
                      finalIndex = i;
                    }
                  }

                  var path =
                      '${snapshot.data?[index].path.split(Platform.pathSeparator).last}';

                  return Material(
                    key: UniqueKey(),
                    color: Colors.transparent,
                    child: FileButton(
                      buttonText: path.endsWith('.md')
                          ? path.substring(0, path.length - 3)
                          : path.endsWith('.markdown')
                              ? path.substring(0, path.length - 9)
                              : path,
                      index: finalIndex,
                      path: snapshot.data?[index].path ?? 'No file path found',
                      isExtended: navigationSizeProvider.isExtendedFileNav,
                      insideFolder: false,
                      setStateCallback: setStateCallback,
                    ),
                  );
                } else {
                  return const Text('Neither file nor directory');
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer2<NavigationSizeProvider, FileNavigationProvider>(builder:
          (context, navigationSizeProvider, fileNavigationProvider, _) {
        final contentFolder = SSG.getSSGContentFolder(
            ssg: SSG.getSSGType(Preferences.getSSG()), pathSeparator: false);
        final savePath = Preferences.getCurrentPath();

        final windowWidth = MediaQuery.of(context).size.width;
        final navigationSize = navigationSizeProvider.navigationWidth;
        final fileNavigationSize = navigationSizeProvider.fileNavigationWidth;
        final editingPageSize =
            windowWidth - (navigationSize + fileNavigationSize);

        var finalSize = fileNavigationSize;
        if (editingPageSize < 250 || windowWidth < mobileWidth) {
          if (fileNavigationSize > 64) {
            finalSize = 200.0;
            lastWidth = 200;
            navigationSizeProvider.setFileNavigationWidth(200, notify: false);
          } else {
            finalSize = 64.0;
          }
        } else {
          finalSize = fileNavigationSize;
        }

        return Stack(
          children: [
            Container(
              width: navigationSizeProvider.isExtendedFileNav
                  ? finalSize > 64
                      ? finalSize
                      : 200
                  : 64.0,
              color: Theme.of(context).colorScheme.secondary,
              child: ContextMenuRegion(
                contextMenu: GenericContextMenu(
                  buttonConfigs: [
                    ContextMenuButtonConfig(
                        Localization.appLocalizations().newPost,
                        icon: const Icon(Icons.post_add, size: 20),
                        onPressed: () => addFile(
                            context: context,
                            mounted: mounted,
                            path: Preferences.getCurrentPath())),
                    AddFolder(context, mounted).addFolderContextMenu(
                        savePath: Preferences.getCurrentPath()),
                    ContextMenuButtonConfig(
                      Localization.appLocalizations().openInFileExplorer,
                      icon: const Icon(Icons.open_in_new, size: 20),
                      onPressed: () => openInFolder(
                        path: savePath,
                        keepPathTrailing: true,
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 4.0, 6.0, 6.0),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                _expandButton(),
                                Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                CustomTooltip(
                                  message:
                                      Localization.appLocalizations().sortBy,
                                  child: SortButton(
                                      setStateCallback: setStateCallback,
                                      isExtended: navigationSizeProvider
                                          .isExtendedFileNav),
                                ),
                                Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                CustomTooltip(
                                  message: Localization.appLocalizations()
                                      .parentFolderButton_Toolip(
                                          savePath.substring(
                                              savePath.indexOf(contentFolder))),
                                  child: ParentFolderButton(
                                      setStateCallback: setStateCallback,
                                      isExtended: navigationSizeProvider
                                          .isExtendedFileNav),
                                ),
                                SizedBox(
                                  height: constraints.maxHeight > mobileWidth
                                      ? constraints.maxHeight - 250
                                      : 250,
                                  child: Scrollbar(
                                    controller: _listScrollController,
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      controller: _listScrollController,
                                      child: Consumer<NavigationProvider>(
                                          builder: (_, __, ___) {
                                        return _listFilesAndDirectories(
                                            navigationSizeProvider);
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                CustomTooltip(
                                  message:
                                      Localization.appLocalizations().newPost,
                                  child: CreateNewButton(
                                      mounted: mounted,
                                      isExtended: navigationSizeProvider
                                          .isExtendedFileNav),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              //top: top + constraints.maxHeight / 2 - 30 / 2,
              top: 0,
              left: left + finalSize - 15 / 2,
              child: ResizeBar(
                maxHeight: constraints.maxHeight,
                onDrag: (dx, dy) {
                  var newWidth =
                      navigationSizeProvider.fileNavigationWidth + dx;
                  lastWidth = newWidth;

                  if (windowWidth > mobileWidth &&
                      editingPageSize < 300 &&
                      dx > 0) {
                  } else {
                    if (newWidth > 200) {
                      navigationSizeProvider.setFileNavigationWidth(newWidth);
                    } else {
                      if (dx > 3.0) {
                        navigationSizeProvider.setFileNavigationWidth(
                            newWidth > 200 ? newWidth : 200);
                        navigationSizeProvider.setIsExtendedFileNav(true);
                      } else {
                        navigationSizeProvider.setFileNavigationWidth(64);
                        navigationSizeProvider.setIsExtendedFileNav(false);
                      }
                    }
                  }
                },
                onEnd: () => Preferences.setFileNavigationSize(finalSize),
              ),
            ),
          ],
        );
      });
    });
  }
}
