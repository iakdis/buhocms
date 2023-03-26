import 'package:buhocms/src/utils/preferences.dart';

enum SSGTypes {
  hugo,
  jekyll,

  none,
}

class SSG {
  static Future<void> setSSG(SSGTypes ssg) async {
    await Preferences.setSSG(ssg.name);
  }

  static String getSSGName() {
    final ssg = SSGTypes.values.byName(Preferences.getSSG());

    switch (ssg) {
      case SSGTypes.hugo:
        return 'Hugo';
      case SSGTypes.jekyll:
        return 'Jekyll';
      default:
        return 'Get name: Unknown SSG';
    }
  }

  static String getSSGExecutable() {
    final ssg = SSGTypes.values.byName(Preferences.getSSG());

    switch (ssg) {
      case SSGTypes.hugo:
        return 'hugo';
      case SSGTypes.jekyll:
        return 'jekyll';
      default:
        return 'Get executable: Unknown SSG';
    }
  }
}
