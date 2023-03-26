import 'package:buhocms/src/utils/preferences.dart';
import 'package:flutter/material.dart';

import '../utils/program_installed.dart';
import '../utils/terminal_command.dart';

enum SSGTypes {
  hugo,
  jekyll,

  none,
}

class SSG {
  static Future<void> setSSG(SSGTypes ssg) async {
    await Preferences.setSSG(ssg.name);
  }

  static Future<void> createSSGWebsite({
    required BuildContext context,
    required SSGTypes ssg,
    required String sitePath,
    required String siteName,
    required String flags,
  }) async {
    //TODO
    switch (ssg) {
      case SSGTypes.hugo:
        final commandToRun = 'hugo new site $siteName $flags';

        checkProgramInstalled(
          context: context,
          command: commandToRun,
          executable: 'hugo',
        );
        await runTerminalCommand(
          context: context,
          workingDirectory: sitePath,
          command: commandToRun,
        );
        break;
      case SSGTypes.jekyll:
        break;
      default:
        break;
    }
  }

  static String getCreateSiteSSGPrefix(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return 'hugo new site ';
      case SSGTypes.jekyll:
        return 'jekyll new ';
      default:
        return 'Get name: Unknown SSG';
    }
  }

  static String getCreateSiteSSGHelper(SSGTypes ssg) {
    switch (ssg) {
      case SSGTypes.hugo:
        return '"hugo new site my-website"';
      case SSGTypes.jekyll:
        return '"jekyll new myblog"';
      default:
        return 'Get name: Unknown SSG';
    }
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
