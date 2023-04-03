import 'dart:io';

import 'package:buhocms/src/provider/editing/editing_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/navigation/file_navigation_provider.dart';
import '../ssg/ssg.dart';
import '../utils/preferences.dart';
import '../widgets/file_navigation/buttons/sort_button.dart';

bool isHidden(FileSystemEntity entity) {
  final websitePath = Preferences.getSitePath() ?? '';
  final path = entity.path.substring(
      websitePath.length,
      entity.path.length -
          ((entity is File)
              ? entity.path.split(Platform.pathSeparator).last.length
              : 0));
  return path.contains('.');
}

Future<void> openInFolder(
    {required String path, required bool keepPathTrailing}) async {
  keepPathTrailing
      ? path = path
      : path = path.substring(
          0, path.indexOf(path.split(Platform.pathSeparator).last));
  final url = Uri(path: path, scheme: 'file');
  if (await canLaunchUrl(url) || Platform.isLinux) {
    await launchUrl(url);
  }
}

Future<void> saveFile(BuildContext context) async {
  final fileNavigationProvider =
      Provider.of<FileNavigationProvider>(context, listen: false);
  final editingProvider = Provider.of<EditingProvider>(context, listen: false);
  final getFiles = await getAllFiles();

  final file = getFiles[fileNavigationProvider.fileNavigationIndex];
  final newText = editingProvider.isGUIMode
      ? '${fileNavigationProvider.frontMatterText}\n\n${fileNavigationProvider.markdownTextContent}'
      : fileNavigationProvider.markdownTextContent;

  await file.writeAsString(newText);

  await fileNavigationProvider.setInitialTexts();
}

Future<List<Directory>> getAllDirectories({BuildContext? context}) async {
  if (context != null) {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);
    await Future.wait(
        [fileNavigationProvider.setInitialTexts(dontExecute: true)]);
  }
  List<Directory> directories = [];

  final contentFolder = SSG.getSSGContentFolder(
      ssg: SSG.getSSGType(Preferences.getSSG()), pathSeparator: false);
  Directory fileDirectory = Directory(Preferences.getCurrentPath()
      .substring(0, Preferences.getCurrentPath().indexOf(contentFolder)));

  var subscription =
      fileDirectory.list(recursive: true, followLinks: false).listen(
    (FileSystemEntity entity) {
      if (entity is Directory) {
        directories.add(entity);
      }
    },
  );

  await Future.wait([subscription.asFuture()]);

  return directories;
}

Future<List<File>> getAllFiles({BuildContext? context}) async {
  if (context != null) {
    final fileNavigationProvider =
        Provider.of<FileNavigationProvider>(context, listen: false);
    await Future.wait(
        [fileNavigationProvider.setInitialTexts(dontExecute: true)]);
  }
  List<File> files = [];

  final contentFolder = SSG.getSSGContentFolder(
      ssg: SSG.getSSGType(Preferences.getSSG()), pathSeparator: false);
  Directory fileDirectory = Directory(Preferences.getCurrentPath().substring(
      0,
      Preferences.getCurrentPath().indexOf(contentFolder) +
          contentFolder.length));

  if (!fileDirectory.existsSync()) return [];

  final subscription =
      fileDirectory.list(recursive: true, followLinks: false).listen(
    (FileSystemEntity entity) {
      if (entity is File && !isHidden(entity)) files.add(entity);
    },
  );

  await Future.wait([subscription.asFuture()]);

  return files;
}

Future<List<FileSystemEntity>> getAllFilesAndDirectoriesInDirectory(
    {required bool recursive, required String path}) async {
  final fileDirectory = Directory(path);

  if (!fileDirectory.existsSync()) return [];

  final filesAndDirectories = <FileSystemEntity>[];

  final subscription =
      fileDirectory.list(recursive: recursive, followLinks: false).listen(
    (FileSystemEntity entity) {
      if (!isHidden(entity)) filesAndDirectories.add(entity);
    },
  );

  await Future.wait([subscription.asFuture()]);

  var sortMode = getSortOrder();
  switch (sortMode) {
    case SortMode.name:
      filesAndDirectories.sort((a, b) {
        var aName = a.path.split(Platform.pathSeparator).last;
        var bName = b.path.split(Platform.pathSeparator).last;
        return aName.compareTo(bName);
      });
      break;
    case SortMode.nameReversed:
      filesAndDirectories.sort((b, a) {
        var aName = a.path.split(Platform.pathSeparator).last;
        var bName = b.path.split(Platform.pathSeparator).last;
        return aName.compareTo(bName);
      });
      break;
    case SortMode.date:
      filesAndDirectories.sort((b, a) {
        var aDate = a.statSync().modified;
        var aFiles = <File>[];
        var bDate = b.statSync().modified;
        var bFiles = <File>[];
        if (a is Directory) {
          if (a.existsSync()) {
            a
                .listSync(recursive: true, followLinks: false)
                .forEach((FileSystemEntity entity) {
              if (entity is File) {
                aFiles.add(entity);
              }
            });
          }
          aFiles.sort((b, a) {
            var aDate = a.statSync().modified;
            var bDate = b.statSync().modified;

            return aDate.compareTo(bDate);
          });
          if (aFiles.isEmpty) {
            aDate = a.statSync().modified;
          } else {
            aDate = aFiles[0].statSync().modified;
          }
        }

        if (b is Directory) {
          if (b.existsSync()) {
            b
                .listSync(recursive: true, followLinks: false)
                .forEach((FileSystemEntity entity) {
              if (entity is File) {
                bFiles.add(entity);
              }
            });
          }
          bFiles.sort((b, a) {
            var aDate = a.statSync().modified;
            var bDate = b.statSync().modified;

            return aDate.compareTo(bDate);
          });
          if (bFiles.isEmpty) {
            bDate = b.statSync().modified;
          } else {
            bDate = bFiles[0].statSync().modified;
          }
        }

        return aDate.compareTo(bDate);
      });
      break;
    case SortMode.dateReversed:
      filesAndDirectories.sort((a, b) {
        var aDate = a.statSync().modified;
        var aFiles = <File>[];
        var bDate = b.statSync().modified;
        var bFiles = <File>[];
        if (a is Directory) {
          if (a.existsSync()) {
            a
                .listSync(recursive: true, followLinks: false)
                .forEach((FileSystemEntity entity) {
              if (entity is File) {
                aFiles.add(entity);
              }
            });
          }
          aFiles.sort((b, a) {
            var aDate = a.statSync().modified;
            var bDate = b.statSync().modified;

            return aDate.compareTo(bDate);
          });
          if (aFiles.isEmpty) {
            aDate = a.statSync().modified;
          } else {
            aDate = aFiles[0].statSync().modified;
          }
        }

        if (b is Directory) {
          if (b.existsSync()) {
            b
                .listSync(recursive: true, followLinks: false)
                .forEach((FileSystemEntity entity) {
              if (entity is File) {
                bFiles.add(entity);
              }
            });
          }
          bFiles.sort((b, a) {
            var aDate = a.statSync().modified;
            var bDate = b.statSync().modified;

            return aDate.compareTo(bDate);
          });
          if (bFiles.isEmpty) {
            bDate = b.statSync().modified;
          } else {
            bDate = bFiles[0].statSync().modified;
          }
        }

        return aDate.compareTo(bDate);
      });
      break;
    case SortMode.size:
      filesAndDirectories.sort((b, a) {
        var aSize = a.statSync().size;
        if (a is Directory) {
          aSize = 0;
          if (a.existsSync()) {
            a
                .listSync(recursive: true, followLinks: false)
                .forEach((FileSystemEntity entity) {
              if (entity is File) {
                aSize += entity.lengthSync();
              }
            });
          }
        }

        var bSize = b.statSync().size;
        if (b is Directory) {
          bSize = 0;
          if (b.existsSync()) {
            b
                .listSync(recursive: true, followLinks: false)
                .forEach((FileSystemEntity entity) {
              if (entity is File) {
                bSize += entity.lengthSync();
              }
            });
          }
        }

        return aSize.compareTo(bSize);
      });
      break;
    case SortMode.sizeReversed:
      filesAndDirectories.sort((a, b) {
        var aSize = a.statSync().size;
        if (a is Directory) {
          aSize = 0;
          if (a.existsSync()) {
            a
                .listSync(recursive: true, followLinks: false)
                .forEach((FileSystemEntity entity) {
              if (entity is File) {
                aSize += entity.lengthSync();
              }
            });
          }
        }

        var bSize = b.statSync().size;
        if (b is Directory) {
          bSize = 0;
          if (b.existsSync()) {
            b
                .listSync(recursive: true, followLinks: false)
                .forEach((FileSystemEntity entity) {
              if (entity is File) {
                bSize += entity.lengthSync();
              }
            });
          }
        }

        return aSize.compareTo(bSize);
      });
      break;
    case SortMode.type:
      filesAndDirectories.sort((a, b) => a is File ? 0 : 1);
      break;
    case SortMode.typeReversed:
      filesAndDirectories.sort((b, a) => a is File ? 0 : 1);
      break;
    default:
  }

  return filesAndDirectories;
}
