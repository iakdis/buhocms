import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';

import '../../../i18n/l10n.dart';

GenericContextMenu folderContextMenus({
  required BuildContext context,
  required ContextMenuButtonConfig addFile,
  required ContextMenuButtonConfig addFolder,
  required Function rename,
  required Function openInFolder,
  required Function delete,
}) {
  return GenericContextMenu(
    buttonConfigs: [
      addFile,
      addFolder,
      ContextMenuButtonConfig(
        Localization.appLocalizations().rename,
        icon: const Icon(Icons.drive_file_rename_outline, size: 20),
        shortcutLabel: 'F2',
        onPressed: () => rename(),
      ),
      ContextMenuButtonConfig(
        Localization.appLocalizations().openInFileExplorer,
        icon: const Icon(Icons.open_in_new, size: 20),
        onPressed: () => openInFolder(),
      ),
      ContextMenuButtonConfig(
        Localization.appLocalizations().delete,
        icon: const Icon(Icons.delete, size: 20),
        shortcutLabel: 'Del',
        onPressed: () => delete(),
      ),
    ],
  );
}
