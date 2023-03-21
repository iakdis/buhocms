import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../provider/editing/editing_provider.dart';

Map<MenuSerializableShortcut, Intent> markdownToolbarShortcuts(
    BuildContext context) {
  final markdownToolbarShortcuts = <MenuSerializableShortcut, Intent>{};
  final markdownToolbarState =
      context.read<EditingProvider>().markdownToolbarKey.currentState;

  markdownToolbarShortcuts.addEntries([
    MapEntry(const SingleActivator(LogicalKeyboardKey.keyB, control: true),
        VoidCallbackIntent(() => markdownToolbarState?.onBoldPressed())),
    MapEntry(const SingleActivator(LogicalKeyboardKey.keyI, control: true),
        VoidCallbackIntent(() => markdownToolbarState?.onItalicPressed())),
    MapEntry(const SingleActivator(LogicalKeyboardKey.keyK, control: true),
        VoidCallbackIntent(() => markdownToolbarState?.onLinkPressed())),
    MapEntry(const SingleActivator(LogicalKeyboardKey.keyP, control: true),
        VoidCallbackIntent(() => markdownToolbarState?.onImagePressed())),
    MapEntry(const SingleActivator(LogicalKeyboardKey.keyE, control: true),
        VoidCallbackIntent(() => markdownToolbarState?.onCodePressed())),
    MapEntry(
        const SingleActivator(LogicalKeyboardKey.digit8,
            control: true, shift: true),
        VoidCallbackIntent(
            () => markdownToolbarState?.onUnorderedListPressed())),
    MapEntry(
        const SingleActivator(LogicalKeyboardKey.digit7,
            control: true, shift: true),
        VoidCallbackIntent(() => markdownToolbarState?.onOrderedListPressed())),
    MapEntry(const SingleActivator(LogicalKeyboardKey.period, control: true),
        VoidCallbackIntent(() => markdownToolbarState?.onQuotePressed())),
    MapEntry(
        const SingleActivator(LogicalKeyboardKey.keyH,
            control: true, shift: true),
        VoidCallbackIntent(
            () => markdownToolbarState?.onHorizontalRulePressed())),
  ]);
  return markdownToolbarShortcuts;
}

class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    print('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }
}

class RenameIntent extends Intent {
  const RenameIntent();
}

class RenameAction extends Action<RenameIntent> {
  RenameAction(this.function);

  final Function function;

  @override
  Object? invoke(covariant RenameIntent intent) {
    function();
    return null;
  }
}

class DeleteIntent extends Intent {
  const DeleteIntent();
}

class DeleteAction extends Action<DeleteIntent> {
  DeleteAction(this.function);

  final Function function;

  @override
  Object? invoke(covariant DeleteIntent intent) {
    function();
    return null;
  }
}
