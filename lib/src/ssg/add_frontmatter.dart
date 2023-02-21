import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../logic/buho_functions.dart';
import '../pages/editing_page.dart';
import '../provider/navigation/file_navigation_provider.dart';
import '../utils/preferences.dart';
import '../utils/unsaved_check.dart';
import '../widgets/snackbar.dart';
import 'hugo.dart';

class AddFrontmatterButton extends StatefulWidget {
  const AddFrontmatterButton({
    required this.editingPageKey,
    super.key,
  });

  final GlobalKey<EditingPageState> editingPageKey;

  @override
  State<AddFrontmatterButton> createState() => _AddFrontmatterButtonState();
}

class _AddFrontmatterButtonState extends State<AddFrontmatterButton> {
  void _addFrontMatter(
      {required String hugoFrontmatter, required HugoType type}) {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);
    String? newLine;
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    switch (type) {
      case HugoType.typeString:
        newLine = '$hugoFrontmatter: "Text"';
        break;
      case HugoType.typeBool:
        newLine = '$hugoFrontmatter: false';
        break;
      case HugoType.typeDate:
        newLine = '$hugoFrontmatter: ${dateFormatter.format(DateTime.now())}';
        break;
      case HugoType.typeList:
        newLine = '$hugoFrontmatter: []';
        break;
    }

    print('New Line: <$newLine> with frontmatter <$hugoFrontmatter>');
    var oldFrontmatterText = fileNavigationProvider.frontMatterText;
    var contains = oldFrontmatterText.contains('---');
    if (!contains) oldFrontmatterText = '---\n';
    final newFrontmatterText =
        '${oldFrontmatterText.substring(0, oldFrontmatterText.length - (contains ? 3 : 0))}$newLine\n---';
    fileNavigationProvider.setFrontMatterText(newFrontmatterText);

    showSnackbar(
      context: context,
      text: AppLocalizations.of(context)!.addedFrontmatter(
          '"$hugoFrontmatter"', '"${type.name.substring(4)}"'),
      seconds: 4,
    );
  }

  void _add(MapEntry<String, HugoType>? option) {
    _addFrontMatter(
      hugoFrontmatter: option?.key ?? 'unknown',
      type: option?.value ?? HugoType.typeString,
    );
    save(
      context: context,
      editingPageKey: widget.editingPageKey,
      checkUnsaved: false,
    );
  }

  Widget _addFrontmatterButton() {
    return SizedBox(
      width: 312,
      child: DropdownSearch<MapEntry<String, HugoType>>(
        items:
            Preferences.getFrontMatterAddList().entries.map((e) => e).toList(),
        popupProps: PopupPropsMultiSelection.menu(
          fit: FlexFit.loose,
          constraints: BoxConstraints.tight(const Size(double.infinity, 512)),
          searchDelay: Duration.zero,
          searchFieldProps: const TextFieldProps(autofocus: true),
          itemBuilder: (context, item, isSelected) {
            return ListTile(
              title: Text(item.key),
              subtitle: Text(item.value.name.substring(4)),
              trailing: const Icon(Icons.add),
            );
          },
          showSearchBox: true,
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.addFrontmatter,
            border: const OutlineInputBorder(),
          ),
        ),
        onChanged: (value) {
          checkUnsavedBeforeFunction(
              editingPageKey: widget.editingPageKey,
              function: () => _add(value));
        },
        itemAsString: (item) => '${item.key} (${item.value.name.substring(4)})',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _addFrontmatterButton();
  }
}
