import 'package:flutter/material.dart';

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
