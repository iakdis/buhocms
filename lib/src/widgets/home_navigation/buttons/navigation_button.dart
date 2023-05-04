import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/navigation/navigation_provider.dart';
import '../../../utils/unsaved_check.dart';
import '../../navigation_button.dart';

class HomeNavigationButton extends StatelessWidget {
  const HomeNavigationButton({
    super.key,
    required this.isExtended,
    required this.icon,
    required this.iconUnselected,
    required this.buttonText,
    required this.page,
  });

  final bool isExtended;
  final IconData icon;
  final IconData iconUnselected;
  final String buttonText;
  final NavigationPage page;

  Widget button(BuildContext context) {
    return Consumer<NavigationProvider>(
        builder: (context, navigationProvider, _) {
      return NavigationButton(
        isExtended: isExtended,
        text: buttonText,
        icon: icon,
        onTap: page == navigationProvider.navigationPage
            ? null
            : () {
                checkUnsavedBeforeFunction(
                    context: context,
                    function: () {
                      final navigationProvider =
                          Provider.of<NavigationProvider>(context,
                              listen: false);
                      navigationProvider.setNavigationPage(page);
                    });
              },
        iconColor: page == navigationProvider.navigationPage
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.onPrimary,
        textStyle: TextStyle(
          color: page == navigationProvider.navigationPage
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.onPrimary,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => button(context);
}
