import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';
import '../../../logic/buho_functions.dart';
import '../../navigation_button.dart';

class CreateNewButton extends StatelessWidget {
  const CreateNewButton({
    super.key,
    required this.mounted,
    required this.isExtended,
  });

  final bool mounted;
  final bool isExtended;

  Widget button(BuildContext context) {
    return NavigationButton(
      isExtended: isExtended,
      text: Localization.appLocalizations().newPost.replaceAll('', '\u{200B}'),
      icon: Icons.add_box,
      onTap: () => addFile(context: context, mounted: mounted),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => button(context);
}
