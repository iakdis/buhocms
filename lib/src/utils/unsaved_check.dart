import 'package:flutter/material.dart';
import '../pages/editing_page.dart';

void checkUnsavedBeforeFunction(
    {required GlobalKey<EditingPageState> editingPageKey,
    required Function() function}) {
  editingPageKey.currentState == null
      ? function()
      : editingPageKey.currentState?.checkUnsavedCustomFunction(
          function: function,
          checkUnsaved: true,
        );
}
