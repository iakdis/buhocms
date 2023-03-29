import 'package:buhocms/src/widgets/ssg_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/editing/editing_provider.dart';
import '../provider/editing/unsaved_text_provider.dart';
import '../provider/navigation/file_navigation_provider.dart';
import '../utils/globals.dart';
import 'editing_page/tabs.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    super.key,
    required this.text,
    this.showTabs = false,
    this.updateFunction,
  });

  final String text;
  final bool showTabs;
  final Function? updateFunction;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  Widget customAppBar(BuildContext context) {
    return AppBar(
      title: Consumer2<UnsavedTextProvider, FileNavigationProvider>(
          builder: (context, _, __, ___) {
        widget.updateFunction?.call();

        return Row(
          children: [
            if (MediaQuery.of(context).size.width > mobileWidth ||
                !widget.showTabs)
              Row(
                children: [
                  const SizedBox(width: 16.0),
                  Text(widget.text),
                  const SizedBox(width: 8.0),
                ],
              ),
            widget.showTabs
                ? Expanded(
                    child: Tabs(
                      frontmatterKeys:
                          context.read<EditingProvider>().frontmatterKeys,
                      setStateCallback: () => setState(() {}),
                    ), //https://github.com/flutter/flutter/issues/75180 shift scroll
                  )
                : Expanded(child: Container()),
            if (widget.showTabs) const SizedBox(width: 8.0),
            const SSGIcon(),
            const SizedBox(width: 8.0),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) => customAppBar(context);
}
