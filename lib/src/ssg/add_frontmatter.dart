import 'package:buhocms/src/provider/editing/frontmatter_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../i18n/l10n.dart';
import '../logic/buho_functions.dart';
import '../utils/preferences.dart';
import '../utils/unsaved_check.dart';
import '../widgets/snackbar.dart';
import 'frontmatter.dart';

class AddFrontmatterButton extends StatefulWidget {
  const AddFrontmatterButton({super.key});

  @override
  State<AddFrontmatterButton> createState() => _AddFrontmatterButtonState();
}

class _AddFrontmatterButtonState extends State<AddFrontmatterButton> {
  void _addFrontMatter(
      {required String frontmatter, required FrontmatterType type}) {
    final frontmatterProvider = context.read<FrontmatterProvider>();

    String? newValue;
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    switch (type) {
      case FrontmatterType.typeString:
        newValue = '"Text"';
        break;
      case FrontmatterType.typeBool:
        newValue = 'false';
        break;
      case FrontmatterType.typeDate:
        newValue = dateFormatter.format(DateTime.now());
        break;
      case FrontmatterType.typeList:
        newValue = '[]';
        break;
    }

    frontmatterProvider.add(MapEntry(frontmatter, newValue));

    showSnackbar(
      text: Localization.appLocalizations()
          .addedFrontmatter('"$frontmatter"', '"${type.name.substring(4)}"'),
      seconds: 4,
    );
  }

  void _add(MapEntry<String, FrontmatterType>? option) {
    _addFrontMatter(
      frontmatter: option?.key ?? 'unknown',
      type: option?.value ?? FrontmatterType.typeString,
    );
    save(
      context: context,
      checkUnsaved: false,
    );
  }

  Widget _addFrontmatterButton() {
    return SizedBox(
      width: 312,
      child: DropdownSearch<MapEntry<String, FrontmatterType>>(
        items:
            Preferences.getFrontMatterAddList().entries.map((e) => e).toList(),
        popupProps: PopupPropsMultiSelection.menu(
          fit: FlexFit.loose,
          constraints: BoxConstraints.tight(const Size(double.infinity, 512)),
          searchDelay: Duration.zero,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: InputDecoration(
              labelText: Localization.appLocalizations().search,
            ),
          ),
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
            labelText: Localization.appLocalizations().addFrontmatter,
            border: const OutlineInputBorder(),
          ),
        ),
        onChanged: (value) {
          checkUnsavedBeforeFunction(
              context: context, function: () => _add(value));
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
