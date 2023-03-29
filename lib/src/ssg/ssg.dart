import 'dart:io';

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

  static String getSSGContentFolder({
    required SSGTypes ssg,
    required bool pathSeparator,
  }) {
    String folder;

    switch (ssg) {
      case SSGTypes.hugo:
        folder = 'content';
        if (pathSeparator) folder = '${Platform.pathSeparator}$folder';
        break;
      case SSGTypes.jekyll:
        folder = '_posts';
        if (pathSeparator) folder = '${Platform.pathSeparator}$folder';
        break;
      default:
        folder = '';
        break;
    }

    return folder;
  }

  static Future<void> createSSGWebsite({
    required BuildContext context,
    required SSGTypes ssg,
    required String sitePath,
    required String siteName,
    required String flags,
  }) async {
    String? executable;
    String allFlags = '';
    switch (ssg) {
      case SSGTypes.hugo:
        executable = 'hugo';
        allFlags = 'new site $siteName';
        if (flags.isNotEmpty) allFlags += ' $flags';
        break;
      case SSGTypes.jekyll:
        executable = 'jekyll';
        allFlags = 'new $siteName';
        if (flags.isNotEmpty) allFlags += ' $flags';
        break;
      default:
        break;
    }

    if (executable == null) return;

    checkProgramInstalled(
      context: context,
      executable: getSSGExecutable(ssg),
      ssg: ssg,
    );
    await runTerminalCommand(
      context: context,
      workingDirectory: sitePath,
      executable: executable,
      flags: allFlags.split(' '),
    );
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
