import 'package:flutter/material.dart';

import '../app.dart';
import '../i18n/l10n.dart';

void showSnackbar({
  required String text,
  required int seconds,
}) {
  var width = (text.length * 20.0) >= 600.0 ? 600.0 : text.length * 20.0;
  width = width <= 300.0 ? 300.0 : width;
  rootScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: const Color(0xFF2C2C2C),
    width: width,
    content: SelectableText(text, style: const TextStyle(color: Colors.white)),
    duration: Duration(seconds: seconds),
    action: SnackBarAction(
      label: Localization.appLocalizations().dismiss,
      onPressed: () {},
      textColor: Colors.white,
    ),
  ));
}
