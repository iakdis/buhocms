import 'package:flutter/material.dart';

void showSnackbar({
  required BuildContext context,
  required String text,
  required int seconds,
}) {
  var width = (text.length * 20.0) >= 600.0 ? 600.0 : text.length * 20.0;
  width = width <= 300.0 ? 300.0 : width;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    width: width,
    content: Text(text),
    duration: Duration(seconds: seconds),
    action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
  ));
}
