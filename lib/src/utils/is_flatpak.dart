import 'dart:io';

import 'package:buhocms/src/app.dart';
import 'package:flutter/material.dart';

import '../i18n/l10n.dart';

Future<bool> isFlatpak() async {
  final result = await Process.run('flatpak-spawn', ['-h'], runInShell: true);
  return result.exitCode == 0 ? true : false;
}

Future<void> showFlatpakDialog() async {
  if (navigatorKey.currentContext == null) return;
  await showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => SimpleDialog(
      contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 12.0, 12.0),
      children: [
        Column(
          children: [
            const Icon(Icons.error_outline, size: 64.0),
            const SizedBox(height: 16.0),
            SelectableText(
              Localization.appLocalizations().flatpakPermission,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: 400,
              child: SelectableText(
                Localization.appLocalizations().flatpakPermission_Description(
                    'flatpak --user override org.buhocms.BuhoCMS --talk-name=org.freedesktop.Flatpak'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 64.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Localization.appLocalizations().close),
            ),
          ],
        ),
      ],
    ),
  );
}
