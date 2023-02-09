import 'dart:io';

import '../utils/preferences.dart';

class HugoThemes {
  static Future<List<Directory>> findAllThemes() async {
    List<Directory> directories = [];

    Directory fileDirectory = Directory(
        '${Preferences.getSitePath()}${Platform.pathSeparator}themes');

    var subscription =
        fileDirectory.list(recursive: false, followLinks: false).listen(
      (FileSystemEntity entity) {
        if (entity is Directory) {
          directories.add(entity);
        }
      },
    );

    await Future.wait([subscription.asFuture()]);

    return directories;
  }
}
