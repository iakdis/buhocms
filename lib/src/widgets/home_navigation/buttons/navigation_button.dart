import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../pages/editing_page.dart';
import '../../../provider/navigation/navigation_provider.dart';
import '../../../utils/unsaved_check.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.editingPageKey,
    required this.isExtended,
    required this.icon,
    required this.iconUnselected,
    required this.buttonText,
    required this.index,
  });

  final GlobalKey<EditingPageState> editingPageKey;
  final bool isExtended;
  final IconData icon;
  final IconData iconUnselected;
  final String buttonText;
  final int index;

  Widget _navigationButton() {
    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        color: Colors.transparent,
        child: Consumer<NavigationProvider>(
            builder: (context, navigationProvider, _) {
          return InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: index == navigationProvider.navigationIndex
                ? null
                : () {
                    checkUnsavedBeforeFunction(
                        editingPageKey: editingPageKey,
                        function: () {
                          final navigationProvider =
                              Provider.of<NavigationProvider>(context,
                                  listen: false);
                          navigationProvider.setNavigationIndex(index);
                        });
                  },
            child: Padding(
              padding: isExtended
                  ? const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0)
                  : const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: isExtended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32.0,
                    color: index == navigationProvider.navigationIndex
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                  isExtended
                      ? Row(
                          children: [
                            const SizedBox(
                              width: 16.0,
                            ),
                            SizedBox(
                              width: constraints.maxWidth - 80,
                              child: Consumer<NavigationProvider>(
                                  builder: (context, navigationProvider, _) {
                                return Text(
                                  buttonText,
                                  style: TextStyle(
                                    color: index ==
                                            navigationProvider.navigationIndex
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                  ),
                                );
                              }),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ), //this.index = index),
          );
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _navigationButton();
  }
}
