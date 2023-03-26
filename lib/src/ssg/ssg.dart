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

  static String getSSGName(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'Hugo';
      case SSGTypes.jekyll:
        return 'Jekyll';
      case SSGTypes.none:
        return 'None';
      default:
        return 'Get name: Unknown SSG';
    }
  }

  static String getSSGExecutable(SSGTypes ssg) {
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
