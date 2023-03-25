import 'dart:ui';

import 'package:buhocms/src/provider/editing/unsaved_text_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yaml/yaml.dart';

import '../i18n/l10n.dart';
import '../logic/buho_functions.dart';
import '../provider/navigation/file_navigation_provider.dart';
import '../utils/preferences.dart';
import '../utils/unsaved_check.dart';
import '../widgets/snackbar.dart';
import 'edit_frontmatter.dart';
import 'hugo.dart';

enum FrontmatterType {
  typeString,
  typeBool,
  typeDate,
  typeList,
}

class FrontmatterWidget extends StatefulWidget {
  const FrontmatterWidget({
    super.key,
    required this.source,
    required this.index,
  });

  final String source;
  final int index;

  @override
  State<FrontmatterWidget> createState() => FrontmatterWidgetState();
}

class FrontmatterWidgetState extends State<FrontmatterWidget> {
  ScrollController scrollController = ScrollController();

  TextEditingController frontMatterController = TextEditingController();
  TextEditingController frontMatterControllerUnsaved = TextEditingController();

  bool? isChecked;
  bool? unsavedIsChecked;

  DateTime? date;
  DateTime? unsavedDate;

  DateFormat formatter = DateFormat('dd.MM.yyyy');
  String? formattedDate;

  List<String> list = [];
  List<String> unsavedList = [];
  TextEditingController listController = TextEditingController();
  late FocusNode listFocusNode;

  late MapEntry<String, FrontmatterType> frontmatter;
  bool frontMatterNotFound = false;

  late Widget frontmatterWidget;
  late VoidCallback restore;
  late VoidCallback save;

  @override
  void initState() {
    final yaml = loadYaml(widget.source) as YamlMap;
    final frontmatterKey = yaml.entries.first.key.toString();
    final frontmatterValue = yaml.entries.first.value.toString();

    if (Preferences.getFrontMatterAddList().keys.contains(frontmatterKey)) {
      frontmatter = Preferences.getFrontMatterAddList()
          .entries
          .firstWhere((element) => element.key == frontmatterKey);
    } else {
      frontmatter = MapEntry(frontmatterKey, FrontmatterType.typeString);
      frontMatterNotFound = true;
    }

    frontMatterController.text = Hugo.getValue(widget.source);
    frontMatterController.text.trim();
    frontMatterControllerUnsaved.text = frontMatterController.text;
    frontMatterControllerUnsaved.addListener(() {
      setState(() {});
    });

    if (frontMatterController.text.contains('true')) {
      isChecked = true;
    } else if (frontMatterController.text.contains('false')) {
      isChecked = false;
    } else {
      isChecked = false;
    }
    unsavedIsChecked = isChecked;

    date = DateTime.tryParse(frontmatterValue);
    date ??= DateTime.now();
    unsavedDate = date;
    formattedDate = formatter.format(unsavedDate!);

    final entry = yaml.entries.first.value;
    if (entry is List) {
      if (entry.isNotEmpty && entry[0].isNotEmpty) {
        list.addAll(entry.map((e) => e));
      }
    }

    unsavedList.clear();
    unsavedList.addAll(list);

    listFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    frontMatterController.dispose();
    frontMatterControllerUnsaved.dispose();

    listController.dispose();
    listFocusNode.dispose();

    scrollController.dispose();

    super.dispose();
  }

  @override
  setState(Function() fn) {
    super.setState(fn);
    final unsavedTextProvider =
        Provider.of<UnsavedTextProvider>(context, listen: false);
    unsavedTextProvider.setUnsaved(checkUnsaved(frontmatter.value));
  }

  bool checkUnsaved(FrontmatterType type) {
    switch (type) {
      case FrontmatterType.typeString:
        return frontMatterControllerUnsaved.text != frontMatterController.text;
      case FrontmatterType.typeBool:
        return unsavedIsChecked != isChecked;
      case FrontmatterType.typeDate:
        return formatter.format(unsavedDate!) != formatter.format(date!);
      case FrontmatterType.typeList:
        if (unsavedList.length == list.length) {
          for (var i = 0; i < list.length; i++) {
            if (unsavedList[i] != list[i]) {
              break;
            }
          }
          return false;
        } else {
          return true;
        }

      default:
        return frontMatterControllerUnsaved.text != frontMatterController.text;
    }
  }

  Widget _textWidget(String source) {
    final yaml = loadYaml(source) as YamlMap;
    var labelText = yaml.entries.first.key.toString();
    labelText = '${labelText[0].toUpperCase()}${labelText.substring(1)}';

    return Wrap(
      spacing: 4.0,
      runSpacing: 8.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('$labelText: '),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: TextField(
            controller: frontMatterControllerUnsaved,
            minLines: 1,
            maxLines: null,
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  void _textRestore() {
    setState(() {
      final oldText = frontMatterController.text;
      frontMatterControllerUnsaved.text = oldText;
    });
  }

  void _textSave() {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);

    final oldText = frontMatterController.text;
    final newText = frontMatterControllerUnsaved.text;

    final yaml = loadYaml(widget.source) as YamlMap;
    final frontmatterKey = yaml.entries.first.key.toString();

    final oldFrontmatterText = fileNavigationProvider.frontMatterText;
    final newFrontmatterText = oldFrontmatterText.replaceFirst(
      '$frontmatterKey: "$oldText"',
      '$frontmatterKey: "$newText"',
    );

    fileNavigationProvider.setFrontMatterText(newFrontmatterText);

    setState(
        () => frontMatterController.text = frontMatterControllerUnsaved.text);
  }

  void _boolSave() {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);

    final oldChecked = isChecked.toString();
    final newChecked = unsavedIsChecked.toString();

    final yaml = loadYaml(widget.source) as YamlMap;
    final frontmatterKey = yaml.entries.first.key.toString();

    final oldFrontmatterText = fileNavigationProvider.frontMatterText;
    final newFrontmatterText = oldFrontmatterText.replaceFirst(
      '$frontmatterKey: $oldChecked',
      '$frontmatterKey: $newChecked',
    );

    fileNavigationProvider.setFrontMatterText(newFrontmatterText);

    setState(() => isChecked = unsavedIsChecked);
  }

  void _dateSave() {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);

    DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final oldDate = date ?? DateTime(2000);
    final newDate = unsavedDate ?? DateTime(2000);
    final formattedOldDate = dateFormatter.format(oldDate);
    final formattedNewDate = dateFormatter.format(newDate);

    final yaml = loadYaml(widget.source) as YamlMap;
    final frontmatterKey = yaml.entries.first.key.toString();

    final oldFrontmatterText = fileNavigationProvider.frontMatterText;
    final newFrontmatterText = oldFrontmatterText.replaceFirst(
      '$frontmatterKey: $formattedOldDate',
      '$frontmatterKey: $formattedNewDate',
    );

    fileNavigationProvider.setFrontMatterText(newFrontmatterText);

    setState(() => date = unsavedDate);
  }

  Widget _boolWidget(String source) {
    frontMatterController.text = Hugo.getValue(source);
    frontMatterController.text.trim();

    final yaml = loadYaml(source) as YamlMap;
    var labelText = yaml.entries.first.key.toString();
    labelText = '${labelText[0].toUpperCase()}${labelText.substring(1)}';

    return SizedBox(
      width: 200,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('$labelText: '),
          Switch(
            value: unsavedIsChecked ?? false,
            onChanged: (value) => setState(() => unsavedIsChecked = value),
          ),
        ],
      ),
    );
  }

  void _boolRestore() {
    setState(() {
      bool? oldChecked = isChecked;
      unsavedIsChecked = oldChecked;
    });
  }

  Widget _dateWidget(String source) {
    frontMatterController.text = Hugo.getValue(source);
    frontMatterController.text.trim();

    final yaml = loadYaml(source) as YamlMap;
    var labelText = yaml.entries.first.key.toString();
    labelText = '${labelText[0].toUpperCase()}${labelText.substring(1)}';

    return SizedBox(
      width: 200,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('$labelText: '),
          TextButton.icon(
            label: Text('$formattedDate'),
            onPressed: () async {
              var newDate = await showDatePicker(
                context: context,
                initialDate: unsavedDate!,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );

              if (newDate == null) return;
              setState(() {
                unsavedDate = newDate;
                formattedDate = formatter.format(unsavedDate!);
              });
            },
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
    );
  }

  void _dateRestore() {
    setState(() {
      DateTime? oldDate = date;
      unsavedDate = oldDate;
      formattedDate = formatter.format(unsavedDate!);
    });
  }

  Widget _listChip(String label) {
    return InputChip(
      deleteIcon: const Icon(Icons.cancel, size: 20),
      deleteIconColor: Theme.of(context).colorScheme.onPrimary,
      deleteButtonTooltipMessage:
          Localization.appLocalizations().removeTag('"$label"'),
      onDeleted: () => setState(
          () => unsavedList.removeWhere((String entry) => entry == label)),
      label: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _listWidget(String source) {
    final yaml = loadYaml(source) as YamlMap;
    var labelText = yaml.entries.first.key.toString();
    labelText = '${labelText[0].toUpperCase()}${labelText.substring(1)}';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('$labelText: '),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 282),
                    child: TextFormField(
                      controller: listController,
                      focusNode: listFocusNode,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.tag),
                        hintText: Localization.appLocalizations().tag,
                      ),
                      autovalidateMode: AutovalidateMode.always,
                      onFieldSubmitted: ((value) {
                        if (value.isNotEmpty) {
                          setState(() => unsavedList.add(value));
                        }
                        listController.clear();
                        listFocusNode.requestFocus();
                      }),
                      onChanged: (value) {
                        if (value == ' ') {
                          listController.clear();
                          return;
                        }
                        if (value == ',') {
                          listController.clear();
                          return;
                        }

                        if (value.contains(' ')) {
                          value = value.substring(0, value.indexOf(' '));
                          setState(() => unsavedList.add(value));
                          listController.clear();
                          listFocusNode.requestFocus();
                        } else if (value.contains(',')) {
                          value = value.substring(0, value.indexOf(','));
                          setState(() => unsavedList.add(value));
                          listController.clear();
                          listFocusNode.requestFocus();
                        }
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      var value = listController.text;
                      if (value.isNotEmpty) {
                        setState(() => unsavedList.add(value));
                      }
                      listController.clear();
                      listFocusNode.requestFocus();
                    },
                    style: const ButtonStyle(
                        fixedSize: MaterialStatePropertyAll(Size(50, 50))),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              Container(
                padding:
                    unsavedList.isNotEmpty ? const EdgeInsets.all(8.0) : null,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                child: Wrap(
                  spacing: 4.0,
                  runSpacing: 6.0,
                  children: unsavedList.map((e) => _listChip(e)).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _listSave() {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);

    final newList = [...unsavedList.map((e) => '"$e"')];

    final yaml = loadYaml(widget.source) as YamlMap;
    final frontmatterKey = yaml.entries.first.key;

    var oldFrontmatterText = fileNavigationProvider.frontMatterText.split('\n')
      ..removeAt(0) // Remove "---""
      ..removeLast(); // Remove "---"

    var newFrontmatterText = oldFrontmatterText;

    for (var i = 0; i < oldFrontmatterText.length; i++) {
      final yaml = loadYaml(oldFrontmatterText[i]) as YamlMap;
      if (yaml.entries.first.key == frontmatterKey) {
        newFrontmatterText[i] = '$frontmatterKey: $newList';
      }
    }

    newFrontmatterText
      ..insert(0, '---') // Add "---"
      ..insert(newFrontmatterText.length, '---'); // Add "---"

    fileNavigationProvider.setFrontMatterText(newFrontmatterText.join('\n'));

    setState(() {
      frontMatterController.text = frontMatterControllerUnsaved.text;
    });
  }

  void _listRestore() {
    setState(() {
      unsavedList.clear();
      unsavedList.addAll(list);
    });
  }

  void _removeFrontMatter() {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);

    var allLines = fileNavigationProvider.frontMatterText.split('\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localization.appLocalizations().deleteFrontmatter),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SelectableText.rich(
            TextSpan(
              text: Localization.appLocalizations().areYouSureDeleteFrontmatter,
              children: <TextSpan>[
                TextSpan(
                  text: allLines[widget.index + 1],
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
            onPressed: () {
              allLines.removeAt(widget.index + 1);
              final newFrontmatterText = allLines.join('\n');

              fileNavigationProvider.setFrontMatterText(newFrontmatterText);

              showSnackbar(
                text: Localization.appLocalizations().removedFrontmatter(
                    '"${frontmatter.key}"',
                    '"${frontmatter.value.name.substring(4)}"'),
                seconds: 4,
              );

              saveFileAndFrontmatter(context: context);

              Navigator.pop(context);
            },
            child: Text(Localization.appLocalizations().yes),
          ),
        ],
      ),
    );
  }

  Widget _horizontalScroll({required Widget child}) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 16.0),
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    restore = () {};
    save = () {};

    switch (frontmatter.value) {
      case FrontmatterType.typeString:
        frontmatterWidget = _textWidget(widget.source);
        restore = _textRestore;
        save = _textSave;
        break;
      case FrontmatterType.typeBool:
        frontmatterWidget = _boolWidget(widget.source);
        restore = _boolRestore;
        save = _boolSave;
        break;
      case FrontmatterType.typeDate:
        frontmatterWidget = _dateWidget(widget.source);
        restore = _dateRestore;
        save = _dateSave;
        break;
      case FrontmatterType.typeList:
        frontmatterWidget = _listWidget(widget.source);
        restore = _listRestore;
        save = _listSave;
        break;
    }

    if (frontMatterNotFound) {
      return _horizontalScroll(
        child: Row(
          children: [
            TextButton.icon(
              onPressed: () => showAutoDialog(
                context: context,
                mounted: mounted,
                setStateFunction: () =>
                    saveFileAndFrontmatter(context: context),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: Text(Localization.appLocalizations().detect),
            ),
            const SizedBox(width: 8.0),
            SizedBox(
              width: 800,
              child: SelectableText(Localization.appLocalizations()
                  .notFound_Description('"${frontmatter.key}"')),
            ),
            Tooltip(
              message: Localization.appLocalizations().delete,
              child: ElevatedButton(
                onPressed: () => checkUnsavedBeforeFunction(
                    context: context, function: () => _removeFrontMatter()),
                child: const Icon(Icons.delete),
              ),
            ),
          ],
        ),
      );
    }

    return _horizontalScroll(
      child: Row(
        children: [
          if (checkUnsaved(frontmatter.value))
            const SizedBox(child: Text('*', style: TextStyle(fontSize: 24))),
          if (checkUnsaved(frontmatter.value)) const VerticalDivider(),
          frontmatterWidget,
          const VerticalDivider(),
          Tooltip(
            message: Localization.appLocalizations().delete,
            child: ElevatedButton(
              onPressed: () => checkUnsavedBeforeFunction(
                  context: context, function: () => _removeFrontMatter()),
              child: const Icon(Icons.delete),
            ),
          ),
          const VerticalDivider(),
          Tooltip(
            message: Localization.appLocalizations().restore,
            child: ElevatedButton(
              onPressed: restore,
              child: const Icon(Icons.restore),
            ),
          ),
        ],
      ),
    );
  }
}
