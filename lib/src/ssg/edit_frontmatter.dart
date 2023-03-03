import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../logic/files.dart';
import '../pages/editing_page.dart';
import '../utils/preferences.dart';
import '../utils/unsaved_check.dart';
import '../widgets/snackbar.dart';
import 'hugo.dart';

Future<Map<String, HugoType>> automaticallyDetectFrontmatter() async {
  final getFiles = await getAllFiles();
  final typeMap = <String, HugoType>{};

  for (var i = 0; i < getFiles.length; i++) {
    final allLines = getFiles[i].readAsLinesSync();
    final frontmatterLines = <String>[];

    var start = 0;
    var end = 0;

    // Get first Front matter dashes
    for (var i = 0; i < allLines.length; i++) {
      if (allLines[i] == '---') {
        start = i;
        break;
      }
    }

    // Get last Front matter dashes
    for (var i = start + 1; i < allLines.length; i++) {
      if (allLines[i] == '---') {
        end = i;
        break;
      }
    }

    // Set actual Front matter entries without dashes
    for (var i = start + 1; i < end; i++) {
      frontmatterLines.add(allLines[i]);
    }

    // Add Front matter entries to a map with key and value pairs
    final map = <String, String>{};
    for (var i = 0; i < frontmatterLines.length; i++) {
      final key =
          frontmatterLines[i].substring(0, frontmatterLines[i].indexOf(':'));
      final value =
          frontmatterLines[i].substring(frontmatterLines[i].indexOf(':') + 1);
      map.addEntries([MapEntry(key.trim(), value.trim())]);
    }

    // Detect type for each key
    final keySet = <String>{};
    for (var i = 0; i < map.entries.length; i++) {
      final key = map.keys.toList()[i];
      final value = map.values.toList()[i];

      if (value == 'true' || value == 'false') {
        if (!keySet.contains(key)) {
          typeMap.addEntries([MapEntry(key, HugoType.typeBool)]);
        }
      } else if (value.contains('[') && value.contains(']')) {
        if (!keySet.contains(key)) {
          typeMap.addEntries([MapEntry(key, HugoType.typeList)]);
        }
      } else if (DateTime.tryParse(value) != null) {
        if (!keySet.contains(key)) {
          typeMap.addEntries([MapEntry(key, HugoType.typeDate)]);
        }
      } else {
        if (!keySet.contains(key)) {
          typeMap.addEntries([MapEntry(key, HugoType.typeString)]);
        }
      }

      keySet.add(key);
    }
  }

  return typeMap;
}

void showAutoDialog({
  required BuildContext context,
  required bool mounted,
  Function? setStateFunction,
}) async {
  final typeMap = await automaticallyDetectFrontmatter();

  if (mounted) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 12.0, 12.0),
            children: [
              Column(
                children: [
                  const Icon(Icons.auto_awesome, size: 64.0),
                  const SizedBox(height: 16.0),
                  SelectableText(
                    AppLocalizations.of(context)!.autoFrontmatterList,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: 400,
                    child: SelectableText(
                      AppLocalizations.of(context)!
                          .areYouSureAutoFrontmatterList,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Preferences.setFrontMatterAddList(typeMap);
                      setStateFunction?.call();
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.yes),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }
}

class EditFrontmatterListButton extends StatefulWidget {
  const EditFrontmatterListButton({Key? key, required this.editingPageKey})
      : super(key: key);

  final GlobalKey<EditingPageState> editingPageKey;

  @override
  State<EditFrontmatterListButton> createState() =>
      _EditFrontmatterListButtonState();
}

class _EditFrontmatterListButtonState extends State<EditFrontmatterListButton> {
  String name = '';
  HugoType type = HugoType.typeString;
  final TextEditingController nameController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final textStyle = const TextStyle(fontSize: 16);

  @override
  void dispose() {
    nameController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void showResetDialog({required Function setStateFunction}) async {
    final map = Preferences.defaultFrontMatterAddList();
    final typeMap = <String, HugoType>{};
    for (var i = 0; i < map.entries.length; i++) {
      final entry = map.entries.toList()[i];
      typeMap.addEntries(
          [MapEntry(entry.key, HugoType.values.byName(entry.value))]);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 12.0, 12.0),
            children: [
              Column(
                children: [
                  const Icon(Icons.restore, size: 64.0),
                  const SizedBox(height: 16.0),
                  SelectableText(
                    AppLocalizations.of(context)!.resetFrontmatterList,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: 300,
                    child: SelectableText(
                      AppLocalizations.of(context)!
                          .areYouSureResetFrontmatterList,
                      style: textStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Preferences.setFrontMatterAddList(typeMap);
                      setStateFunction();
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.yes),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  void editFrontMatterList() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final items = Preferences.getFrontMatterAddList().entries.toList();
          setStateFunction() => setState(() {});

          return LayoutBuilder(builder: (context, constraints) {
            return SimpleDialog(
              contentPadding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 12.0),
              children: [
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.editFrontmatterList,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16.0),
                    Text(AppLocalizations.of(context)!
                        .editFrontmatterList_Description),
                    const SizedBox(height: 16.0),
                    Tooltip(
                      message:
                          'https://gohugo.io/content-management/front-matter/',
                      child: TextButton.icon(
                        onPressed: () async {
                          final url = Uri(
                              scheme: 'https',
                              path:
                                  'gohugo.io/content-management/front-matter/');
                          if (await canLaunchUrl(url) || Platform.isLinux) {
                            await launchUrl(url);
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: Text(AppLocalizations.of(context)!
                            .openHugoDocumentation),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: () => showAutoDialog(
                        context: context,
                        mounted: mounted,
                        setStateFunction: setStateFunction,
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Automatically detect Front matter'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 400,
                    height: constraints.maxHeight * 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 6.0,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6.0)),
                      ),
                      child: ReorderableListView(
                        scrollController: scrollController,
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;

                            final item = items.removeAt(oldIndex);
                            items.insert(newIndex, item);
                            Preferences.setFrontMatterAddList(
                                {for (var v in items) v.key: v.value});
                          });
                        },
                        children: [
                          for (var i = 0; i < items.length; i++)
                            ListTile(
                              key: ValueKey(items[i]),
                              title: Wrap(
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Text(items[i].key),
                                    Wrap(
                                      runSpacing: 4,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            checkUnsavedBeforeFunction(
                                              editingPageKey:
                                                  widget.editingPageKey,
                                              function: () => _edit(items[i],
                                                  setStateFunction:
                                                      setStateFunction),
                                            );
                                          },
                                          icon: const Icon(Icons.edit),
                                          label: Text(
                                              AppLocalizations.of(context)!
                                                  .edit),
                                        ),
                                        const SizedBox(width: 8.0),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            checkUnsavedBeforeFunction(
                                              editingPageKey:
                                                  widget.editingPageKey,
                                              function: () => _remove(items[i],
                                                  setStateFunction:
                                                      setStateFunction),
                                            );
                                          },
                                          icon: const Icon(Icons.remove),
                                          label: Text(
                                              AppLocalizations.of(context)!
                                                  .remove),
                                        ),
                                      ],
                                    ),
                                  ]),
                              subtitle: Text(items[i].value.name.substring(4)),
                              leading: ReorderableDragStartListener(
                                  index: i,
                                  child: const Icon(Icons.drag_handle)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        checkUnsavedBeforeFunction(
                          editingPageKey: widget.editingPageKey,
                          function: () => addNewFrontMatterTypes(
                              setStateFunction: setStateFunction),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context)!
                          .addNewFrontmatterToList),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          showResetDialog(setStateFunction: setStateFunction),
                      icon: const Icon(Icons.restore),
                      label: const Text('Reset Front matter list'),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                  ],
                ),
              ],
            );
          });
        });
      },
    );
    //addNewFrontMatterTypes
  }

  void addNewFrontMatterTypes({required Function setStateFunction}) {
    showEditDialog(
      title: AppLocalizations.of(context)!.addNewFrontmatterToList,
      okText: AppLocalizations.of(context)!.add,
      checkAlreadyContains: true,
      onPressed: () {
        Map<String, HugoType> frontMatterAddList =
            Preferences.getFrontMatterAddList();
        frontMatterAddList.addEntries([MapEntry(name, type)]);

        Preferences.setFrontMatterAddList(frontMatterAddList);

        if (mounted) {
          showSnackbar(
            text: AppLocalizations.of(context)!.addedFrontmatterToList(
                '"$name"', '"${type.name.substring(4)}"'),
            seconds: 4,
          );

          Navigator.pop(context);
        }

        setStateFunction();

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      },
    );
  }

  void showEditDialog({
    required String title,
    required String okText,
    required Function onPressed,
    String? customName,
    HugoType? customType,
    bool checkAlreadyContains = false,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        if (customName != null) {
          name = customName;
          nameController.text = name;
        }
        if (customType != null) {
          type = customType;
        }
        var empty = name.isEmpty;
        Map<String, HugoType> frontMatterAddList =
            Preferences.getFrontMatterAddList();
        var oldName = name;
        var alreadyContains = oldName == name && !checkAlreadyContains
            ? false
            : frontMatterAddList.containsKey(name);

        final FocusNode nameFocusNode = FocusNode();
        nameFocusNode.requestFocus();
        nameController.selection = TextSelection(
            baseOffset: 0, extentOffset: nameController.text.length);

        return LayoutBuilder(builder: (context, constraints) {
          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
              contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 12.0, 12.0),
              children: [
                Column(
                  children: [
                    const Icon(Icons.dashboard_customize, size: 64.0),
                    const SizedBox(height: 16.0),
                    SelectableText(
                      title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.frontmatterName,
                        style: textStyle),
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 200, maxWidth: 300),
                      child: IntrinsicWidth(
                        child: TextField(
                          controller: nameController,
                          focusNode: nameFocusNode,
                          onChanged: (value) {
                            setState(() {
                              name = value;
                              empty = name.isEmpty;
                              if (checkAlreadyContains || oldName != name) {
                                alreadyContains =
                                    frontMatterAddList.containsKey(name);
                              } else {
                                alreadyContains = false;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'title',
                            errorText: empty
                                ? AppLocalizations.of(context)!.cantBeEmpty
                                : alreadyContains
                                    ? AppLocalizations.of(context)!
                                        .error_FrontmatterAlreadyContains
                                    : null,
                            errorMaxLines: 5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.frontmatterType,
                        style: textStyle),
                    DropdownButton(
                      value: type,
                      items: HugoType.values.map((element) {
                        return DropdownMenuItem(
                          value: element,
                          child: Text(element.name.substring(4)),
                        );
                      }).toList(),
                      onChanged: (option) async {
                        setState(() {
                          type = option ?? HugoType.typeString;
                        });
                        //
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 64),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: empty || alreadyContains
                          ? null
                          : () {
                              onPressed();
                            },
                      child: Text(okText),
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

  void _edit(
    MapEntry<String, HugoType> element, {
    required Function setStateFunction,
  }) {
    var oldName = element.key;
    var oldType = element.value;
    showEditDialog(
      title: AppLocalizations.of(context)!.editFrontmatter,
      okText: AppLocalizations.of(context)!.save,
      customName: oldName,
      customType: oldType,
      onPressed: () {
        Map<String, HugoType> frontMatterAddList =
            Preferences.getFrontMatterAddList();
        var tmpLst = frontMatterAddList.entries
            .map((e) => MapEntry(e.key, e.value))
            .toList();

        var index = -1;
        tmpLst.asMap().forEach(
          (key, value) {
            if (value.key == oldName) index = key;
          },
        );
        tmpLst.removeAt(index);
        tmpLst.insert(index, MapEntry(name, type));

        frontMatterAddList.clear();

        for (var mapEntry in tmpLst) {
          frontMatterAddList[mapEntry.key] = mapEntry.value;
        }

        Preferences.setFrontMatterAddList(frontMatterAddList);

        if (mounted) {
          showSnackbar(
            text: AppLocalizations.of(context)!.editedFrontmatterToList(
                '"$oldName"',
                '"$name"',
                '"${oldType.name.substring(4)}"',
                '"${type.name.substring(4)}"'),
            seconds: 4,
          );

          Navigator.pop(context);
        }

        setStateFunction();
      },
    );
  }

  void _remove(
    MapEntry<String, HugoType> element, {
    required Function setStateFunction,
  }) {
    Map<String, HugoType> frontMatterAddList =
        Preferences.getFrontMatterAddList();
    frontMatterAddList.remove(element.key);
    Preferences.setFrontMatterAddList(frontMatterAddList);

    if (mounted) {
      showSnackbar(
        text: AppLocalizations.of(context)!
            .removedFrontmatterToList('"${element.key}"', '"${element.value}"'),
        seconds: 4,
      );
    }

    setStateFunction();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        checkUnsavedBeforeFunction(
            editingPageKey: widget.editingPageKey,
            function: () => editFrontMatterList());
      },
      icon: const Icon(Icons.edit),
      label: Text(AppLocalizations.of(context)!.editFrontmatterList),
    );
  }
}
