import 'dart:io';

import 'package:buhocms/src/ssg/ssg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../i18n/l10n.dart';
import '../utils/preferences.dart';
import '../utils/unsaved_check.dart';
import 'frontmatter.dart';

class EditSSGExecutablesButton extends StatefulWidget {
  const EditSSGExecutablesButton({Key? key}) : super(key: key);

  @override
  State<EditSSGExecutablesButton> createState() =>
      _EditSSGExecutablesButtonState();
}

class _EditSSGExecutablesButtonState extends State<EditSSGExecutablesButton> {
  List<String> text = [''];
  FrontmatterType type = FrontmatterType.typeString;
  final Map<SSGTypes, List<TextEditingController>> textControllers = {};
  final ScrollController scrollController = ScrollController();
  SSGTypes ssg = SSG.getSSGType(Preferences.getSSG());
  List<bool> isEmpty = [];

  final textStyle = const TextStyle(fontSize: 16);

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < SSGTypes.values.length; i++) {
      final textControllersList = <TextEditingController>[];
      for (var j = 0;
          j < SSG.getSSGExecutable(SSGTypes.values[i], skipCustom: true).length;
          j++) {
        textControllersList.add(TextEditingController());
      }
      textControllers
          .addEntries([MapEntry(SSGTypes.values[i], textControllersList)]);
    }
    refreshText();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void refreshText() {
    final map = Preferences.getSSGExecutablesList();
    text = map[ssg]!;
    isEmpty = [for (var i = 0; i < text.length; i++) false];
    for (var i = 0;
        i < SSG.getSSGExecutable(ssg, skipCustom: true).length;
        i++) {
      textControllers[ssg]?[i].text = text[i];
      isEmpty[i] = text[i].isEmpty ? true : false;
    }
  }

  Future<void> save() async {
    final map = {...Preferences.getSSGExecutablesList()};
    map[ssg] = text;
    await Preferences.setSSGExecutablesList(map);
  }

  void showSSGExecutableList() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return LayoutBuilder(builder: (context, constraints) {
            return SimpleDialog(
              contentPadding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 12.0),
              children: [
                Column(
                  children: [
                    SelectableText(
                      Localization.appLocalizations().setCustomSSGExecutables,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: 512.0,
                      child: SelectableText(Localization.appLocalizations()
                          .setCustomSSGExecutables_description),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
                const SizedBox(height: 16.0),
                Column(
                  children: [
                    SizedBox(
                      width: 128.0,
                      child: DropdownButton<SSGTypes>(
                        isExpanded: true,
                        value: ssg,
                        icon: SvgPicture.asset(
                          'assets/images/${SSG.getSSGName(ssg).toLowerCase()}.svg',
                          width: 26,
                          height: 26,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                          semanticsLabel: Localization.appLocalizations()
                              .currentSSG(SSG.getSSGName(ssg)),
                        ),
                        items: SSGTypes.values
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text(SSG.getSSGName(e))))
                            .toList(),
                        onChanged: (option) async {
                          if (option == null) return;
                          ssg = option;
                          refreshText();
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Column(
                      children: [
                        RadioListTile(
                          value: false,
                          groupValue:
                              Preferences.getUseCustomExecutables()[ssg],
                          onChanged: (value) {
                            final map = {
                              ...Preferences.getUseCustomExecutables()
                            };
                            map[ssg] = false;
                            Preferences.setUseCustomExecutables(map);
                            setState(() {});
                          },
                          title: Text(Localization.appLocalizations()
                              .autoSSGExecutables(SSG.getSSGName(ssg))),
                        ),
                        RadioListTile(
                          value: true,
                          groupValue:
                              Preferences.getUseCustomExecutables()[ssg],
                          onChanged: (value) {
                            final map = {
                              ...Preferences.getUseCustomExecutables()
                            };
                            map[ssg] = true;
                            Preferences.setUseCustomExecutables(map);
                            setState(() {});
                          },
                          title: Text(Localization.appLocalizations()
                              .customSSGExecutables(SSG.getSSGName(ssg))),
                        ),
                      ],
                    ),
                    if (Preferences.getUseCustomExecutables()[ssg] == true)
                      Column(
                        children: [
                          for (var i = 0;
                              i <
                                  SSG
                                      .getSSGExecutable(ssg, skipCustom: true)
                                      .length;
                              i++)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 24.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: textControllers[ssg]?[i],
                                      onChanged: (value) {
                                        setState(() {
                                          text[i] = value;
                                          if (value.isNotEmpty) {
                                            isEmpty[i] = false;
                                          } else {
                                            isEmpty[i] = true;
                                          }
                                          save();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        icon: SelectableText(
                                            SSG.getSSGExecutable(ssg,
                                                skipCustom: true)[i],
                                            style: textStyle),
                                        errorText: isEmpty[i]
                                            ? Localization.appLocalizations()
                                                .cantBeEmpty
                                            : null,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result =
                                          await FilePicker.platform.pickFiles(
                                        initialDirectory:
                                            Preferences.getSitePath(),
                                      );

                                      if (result == null ||
                                          result.files.single.path == null) {
                                        return;
                                      }

                                      final file =
                                          File(result.files.single.path!);
                                      text[i] = file.path;
                                      textControllers[ssg]?[i].text = text[i];
                                      save();
                                    },
                                    icon: const Icon(Icons.upload),
                                    label: Text(Localization.appLocalizations()
                                        .selectExecutable),
                                  ),
                                ],
                              ),
                            ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        checkUnsavedBeforeFunction(
            context: context, function: () => showSSGExecutableList());
      },
      icon: const Icon(Icons.edit),
      label: Text(Localization.appLocalizations().setCustomSSGExecutables),
    );
  }
}
