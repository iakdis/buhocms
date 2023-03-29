import 'package:flutter/material.dart';

import '../../utils/preferences.dart';

class SSGProvider extends ChangeNotifier {
  String _ssg = Preferences.getSSG();
  String get ssg => _ssg;

  void setSSG(String ssg) {
    _ssg = ssg;
    notifyListeners();
  }
}
