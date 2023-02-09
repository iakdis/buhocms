import 'package:buhocms/src/app.dart';
import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preferences.init();

  runApp(const App());
}
