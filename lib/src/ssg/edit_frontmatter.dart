import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';

import '../i18n/l10n.dart';
import '../logic/files.dart';
import '../utils/preferences.dart';
import '../utils/unsaved_check.dart';
import '../widgets/snackbar.dart';
import 'frontmatter.dart';

Future<Map<String, FrontmatterType>> automaticallyDetectFrontmatter() async {
  final getFiles = await getAllFiles();
  final typeMap = <String, FrontmatterType>{};

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

    // Detect type for each key
    final keySet = <String>{};
    for (var i = 0; i < frontmatterLines.length; i++) {
      final yaml = loadYaml(frontmatterLines[i]) as YamlMap;
      final key = yaml.entries.first.key.toString();
      final value = yaml.entries.first.value;

      if (value is bool) {
        if (!keySet.contains(key)) {
          typeMap.addEntries([MapEntry(key, FrontmatterType.typeBool)]);
        }
      } else if (value is List) {
        if (!keySet.contains(key)) {
          typeMap.addEntries([MapEntry(key, FrontmatterType.typeList)]);
        }
      } else if (DateTime.tryParse(value.toString()) != null) {
        if (!keySet.contains(key)) {
          typeMap.addEntries([MapEntry(key, FrontmatterType.typeDate)]);
        }
      } else {
        if (!keySet.contains(key)) {
          typeMap.addEntries([MapEntry(key, FrontmatterType.typeString)]);
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
                    Localization.appLocalizations().autoFrontmatterList,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: 400,
                    child: SelectableText(
                      Localization.appLocalizations()
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
                    child: Text(Localization.appLocalizations().cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Preferences.setFrontMatterAddList(typeMap);
                      setStateFunction?.call();
                      Navigator.pop(context);
                    },
                    child: Text(Localization.appLocalizations().yes),
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
  const EditFrontmatterListButton({Key? key}) : super(key: key);

  @override
  State<EditFrontmatterListButton> createState() =>
      _EditFrontmatterListButtonState();
}

class _EditFrontmatterListButtonState extends State<EditFrontmatterListButton> {
  String name = '';
  FrontmatterType type = FrontmatterType.typeString;
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
    final typeMap = <String, FrontmatterType>{};
    for (var i = 0; i < map.entries.length; i++) {
      final entry = map.entries.toList()[i];
      typeMap.addEntries(
          [MapEntry(entry.key, FrontmatterType.values.byName(entry.value))]);
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
                    Localization.appLocalizations().resetFrontmatterList,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: 300,
                    child: SelectableText(
                      Localization.appLocalizations()
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
                    child: Text(Localization.appLocalizations().cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Preferences.setFrontMatterAddList(typeMap);
                      setStateFunction();
                      Navigator.pop(context);
                    },
                    child: Text(Localization.appLocalizations().yes),
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
                      Localization.appLocalizations().editFrontmatterList,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: 512.0,
                      child: Text(Localization.appLocalizations()
                          .editFrontmatterList_Description),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: () => showAutoDialog(
                        context: context,
                        mounted: mounted,
                        setStateFunction: setStateFunction,
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                          Localization.appLocalizations().autoFrontmatterList),
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
                                              context: context,
                                              function: () => _edit(items[i],
                                                  setStateFunction:
                                                      setStateFunction),
                                            );
                                          },
                                          icon: const Icon(Icons.edit),
                                          label: Text(
                                              Localization.appLocalizations()
                                                  .edit),
                                        ),
                                        const SizedBox(width: 8.0),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            checkUnsavedBeforeFunction(
                                              context: context,
                                              function: () => _remove(items[i],
                                                  setStateFunction:
                                                      setStateFunction),
                                            );
                                          },
                                          icon: const Icon(Icons.remove),
                                          label: Text(
                                              Localization.appLocalizations()
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
                          context: context,
                          function: () => addNewFrontMatterTypes(
                              setStateFunction: setStateFunction),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(Localization.appLocalizations().addNewEntry),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          showResetDialog(setStateFunction: setStateFunction),
                      icon: const Icon(Icons.restore),
                      label: Text(
                          Localization.appLocalizations().resetFrontmatterList),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(Localization.appLocalizations().close),
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
      title: Localization.appLocalizations().addNewEntry,
      okText: Localization.appLocalizations().add,
      checkAlreadyContains: true,
      onPressed: () {
        Map<String, FrontmatterType> frontMatterAddList =
            Preferences.getFrontMatterAddList();
        frontMatterAddList.addEntries([MapEntry(name, type)]);

        Preferences.setFrontMatterAddList(frontMatterAddList);

        if (mounted) {
          showSnackbar(
            text: Localization.appLocalizations().addedFrontmatterToList(
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
    FrontmatterType? customType,
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
        Map<String, FrontmatterType> frontMatterAddList =
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
                    Text(Localization.appLocalizations().frontmatterName,
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
                                ? Localization.appLocalizations().cantBeEmpty
                                : alreadyContains
                                    ? Localization.appLocalizations()
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
                    Text(Localization.appLocalizations().frontmatterType,
                        style: textStyle),
                    DropdownButton(
                      value: type,
                      items: FrontmatterType.values.map((element) {
                        return DropdownMenuItem(
                          value: element,
                          child: Text(element.name.substring(4)),
                        );
                      }).toList(),
                      onChanged: (option) async {
                        setState(() {
                          type = option ?? FrontmatterType.typeString;
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
                      child: Text(Localization.appLocalizations().cancel),
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
    MapEntry<String, FrontmatterType> element, {
    required Function setStateFunction,
  }) {
    var oldName = element.key;
    var oldType = element.value;
    showEditDialog(
      title: Localization.appLocalizations().editFrontmatter,
      okText: Localization.appLocalizations().save,
      customName: oldName,
      customType: oldType,
      onPressed: () {
        Map<String, FrontmatterType> frontMatterAddList =
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
            text: Localization.appLocalizations().editedFrontmatterToList(
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
    MapEntry<String, FrontmatterType> element, {
    required Function setStateFunction,
  }) {
    Map<String, FrontmatterType> frontMatterAddList =
        Preferences.getFrontMatterAddList();
    frontMatterAddList.remove(element.key);
    Preferences.setFrontMatterAddList(frontMatterAddList);

    if (mounted) {
      showSnackbar(
        text: Localization.appLocalizations()
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
            context: context, function: () => editFrontMatterList());
      },
      icon: const Icon(Icons.edit),
      label: Text(Localization.appLocalizations().editFrontmatterList),
    );
  }
}
