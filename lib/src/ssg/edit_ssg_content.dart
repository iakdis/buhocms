import 'dart:io';

import 'package:buhocms/src/ssg/ssg.dart';
import 'package:buhocms/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../i18n/l10n.dart';
import '../provider/navigation/file_navigation_provider.dart';
import '../provider/navigation/navigation_provider.dart';
import '../utils/preferences.dart';
import '../utils/unsaved_check.dart';
import 'frontmatter.dart';

class EditSSGContentButton extends StatefulWidget {
  const EditSSGContentButton({Key? key}) : super(key: key);

  @override
  State<EditSSGContentButton> createState() => _EditSSGContentButtonState();
}

class _EditSSGContentButtonState extends State<EditSSGContentButton> {
  String text = '';
  String textOld = '';
  FrontmatterType type = FrontmatterType.typeString;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  SSGTypes ssg = SSG.getSSGType(Preferences.getSSG());

  final textStyle = const TextStyle(fontSize: 16);

  @override
  void initState() {
    super.initState();
    refreshText();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void refreshText() {
    final map = Preferences.getSSGContentList();
    text = map[ssg] ?? '';
    textOld = text;
    textController.text = text;
  }

  Future<void> save() async {
    final navigationProvider = context.read<NavigationProvider>();
    final fileNavigationProvider = context.read<FileNavigationProvider>();

    final map = {...Preferences.getSSGContentList()};
    map[ssg] = text;
    await Preferences.setSSGContentList(map);

    showSnackbar(
        text: Localization.appLocalizations()
            .changedContentFolderTo(SSG.getSSGName(ssg), textOld, text),
        seconds: 4);
    textOld = text;

    if (ssg == SSGTypes.values.byName(Preferences.getSSG())) {
      await Preferences.setCurrentPath(
          '${Preferences.getSitePath()}${Platform.pathSeparator}$text');
    }

    navigationProvider.notifyAllListeners();
    fileNavigationProvider.notifyAllListeners();
  }

  void reset({required Function setStateFunction}) async {
    final map = {...SSG.defaultSSGContentList()};
    text = map[ssg.name] ?? '';
    textController.text = text;
    await save();
    setStateFunction();
    if (mounted) Navigator.pop(context);
  }

  void showResetDialog({required Function setStateFunction}) async {
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
                    Localization.appLocalizations()
                        .resetSSGContent(SSG.getSSGName(ssg)),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: 300,
                    child: SelectableText(
                      Localization.appLocalizations()
                          .resetSSGContent_description(
                              SSG.getSSGName(ssg),
                              SSG.defaultSSGContentList()[ssg.name] ??
                                  SSGTypes.hugo.name),
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
                    onPressed: () => reset(setStateFunction: setStateFunction),
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

  void showSSGList() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          setStateFunction() => setState(() {});

          return LayoutBuilder(builder: (context, constraints) {
            return SimpleDialog(
              contentPadding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 12.0),
              children: [
                Column(
                  children: [
                    SelectableText(
                      Localization.appLocalizations().changeSSGContent,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: 512.0,
                      child: SelectableText(Localization.appLocalizations()
                          .changeSSGContent_description),
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
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: textController,
                        onChanged: (value) {
                          setState(() {
                            text = value;
                          });
                        },
                        decoration: InputDecoration(
                          helperText: '"posts", "content/posts", "_posts", ...',
                          icon: SelectableText(
                              Localization.appLocalizations()
                                  .contentFolderSSG(SSG.getSSGName(ssg)),
                              style: textStyle),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => save(),
                      icon: const Icon(Icons.save),
                      label: Text(Localization.appLocalizations().save),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          showResetDialog(setStateFunction: setStateFunction),
                      icon: const Icon(Icons.restore),
                      label: Text(Localization.appLocalizations()
                          .resetSSG(SSG.getSSGName(ssg))),
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
            context: context, function: () => showSSGList());
      },
      icon: const Icon(Icons.edit),
      label: Text(Localization.appLocalizations().changeSSGContent),
    );
  }
}
