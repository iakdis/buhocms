import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

GenericContextMenu fileContextMenus({
  required BuildContext context,
  required Function open,
  required Function rename,
  required Function openInFolder,
  required Function delete,
}) {
  return GenericContextMenu(
    buttonConfigs: [
      ContextMenuButtonConfig(
        AppLocalizations.of(context)!.rename,
        icon: const Icon(Icons.drive_file_rename_outline, size: 20),
        shortcutLabel: 'F2',
        onPressed: () => rename(),
      ),
      ContextMenuButtonConfig(
        AppLocalizations.of(context)!.openInFileExplorer,
        icon: const Icon(Icons.open_in_new, size: 20),
        onPressed: () => openInFolder(),
      ),
      ContextMenuButtonConfig(
        AppLocalizations.of(context)!.delete,
        icon: const Icon(Icons.delete, size: 20),
        shortcutLabel: 'Del',
        onPressed: () => delete(),
      ),
    ],
  );
}
