import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';
import '../../../utils/preferences.dart';

class SortButton extends StatefulWidget {
  const SortButton({
    super.key,
    required this.setStateCallback,
    required this.isExtended,
  });

  final Function setStateCallback;
  final bool isExtended;

  @override
  State<SortButton> createState() => _SortButtonState();
}

class _SortButtonState extends State<SortButton> {
  String getSortOrderName(String getSortMode) {
    if (getSortMode == SortMode.name.name) {
      return Localization.appLocalizations().sortByName;
    } else if (getSortMode == SortMode.nameReversed.name) {
      return Localization.appLocalizations().sortByNameReversed;
    } else if (getSortMode == SortMode.date.name) {
      return Localization.appLocalizations().sortByDate;
    } else if (getSortMode == SortMode.dateReversed.name) {
      return Localization.appLocalizations().sortByDateReversed;
    } else if (getSortMode == SortMode.size.name) {
      return Localization.appLocalizations().sortBySize;
    } else if (getSortMode == SortMode.sizeReversed.name) {
      return Localization.appLocalizations().sortBySizeReversed;
    } else if (getSortMode == SortMode.type.name) {
      return Localization.appLocalizations().sortByType;
    } else if (getSortMode == SortMode.typeReversed.name) {
      return Localization.appLocalizations().sortByTypeReversed;
    } else {
      return 'Unknown sort order';
    }
  }

  Widget sortButton(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(50.0)),
      child: Material(
        color: Colors.transparent,
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            value: getSortOrder(),
            onChanged: (value) {
              Preferences.setSortMode(value ?? SortMode.name);
              widget.setStateCallback();
            },
            items: SortMode.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Tooltip(
                        message: getSortOrderName(e.name),
                        child: Text(
                          getSortOrderName(e.name).replaceAll('', '\u{200B}'),
                          softWrap: false,
                          maxLines: 1,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ))
                .toList(),
            selectedItemBuilder: (context) => SortMode.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.sort,
                                size: 32.0,
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                            const SizedBox(width: 16.0),
                            Flexible(
                              child: Text(
                                getSortOrderName(e.name),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
            icon: !widget.isExtended
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.sort,
                      size: 32.0,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  )
                : Container(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => sortButton(context);
}

enum SortMode {
  name,
  nameReversed,
  date,
  dateReversed,
  size,
  sizeReversed,
  type,
  typeReversed,
}

SortMode getSortOrder() {
  String getSortMode = Preferences.getSortMode();
  if (getSortMode == SortMode.name.name) {
    return SortMode.name;
  } else if (getSortMode == SortMode.nameReversed.name) {
    return SortMode.nameReversed;
  } else if (getSortMode == SortMode.date.name) {
    return SortMode.date;
  } else if (getSortMode == SortMode.dateReversed.name) {
    return SortMode.dateReversed;
  } else if (getSortMode == SortMode.size.name) {
    return SortMode.size;
  } else if (getSortMode == SortMode.sizeReversed.name) {
    return SortMode.sizeReversed;
  } else if (getSortMode == SortMode.type.name) {
    return SortMode.type;
  } else if (getSortMode == SortMode.typeReversed.name) {
    return SortMode.typeReversed;
  } else {
    return SortMode.name;
  }
}
