import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/editing/editing_provider.dart';

void checkUnsavedBeforeFunction(
    {required BuildContext context, required Function() function}) {
  final editingPageKey = context.read<EditingProvider>().editingPageKey;
  editingPageKey.currentState == null
      ? function()
      : editingPageKey.currentState?.checkUnsavedCustomFunction(
          function: function,
          checkUnsaved: true,
        );
}
