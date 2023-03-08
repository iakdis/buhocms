import 'package:buhocms/src/provider/app/output_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TerminalOutputDrawer extends StatefulWidget {
  const TerminalOutputDrawer({super.key});

  @override
  State<TerminalOutputDrawer> createState() => _TerminalOutputDrawerState();
}

class _TerminalOutputDrawerState extends State<TerminalOutputDrawer> {
  late final ScrollController controller;

  @override
  void initState() {
    controller = ScrollController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final headerText = AppLocalizations.of(context)!.terminalOutput;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<OutputProvider>(
          builder: (context, outputProvider, _) {
            if (outputProvider.showOutput) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.animateTo(
                  controller.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              });
            }

            return outputProvider.showOutput
                ? Container(
                    width: 400,
                    color: Colors.black87,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: constraints.maxHeight,
                            width: 8.0,
                            color: Colors.black,
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 48.0),
                                  child: SingleChildScrollView(
                                    controller: controller,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                        minWidth: constraints.maxWidth,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8.0, 0, 8.0, 8.0),
                                        child: SelectableText(
                                          outputProvider.output,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 4.0, 4.0, 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        tooltip:
                                            AppLocalizations.of(context)!.close,
                                        onPressed: () =>
                                            outputProvider.setShowOutput(false),
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Flexible(
                                        child: Tooltip(
                                          message: headerText,
                                          child: Text(
                                            headerText.replaceAll(
                                                '', '\u{200B}'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip:
                                            AppLocalizations.of(context)!.reset,
                                        onPressed: () =>
                                            outputProvider.clearOutput(),
                                        icon: const Icon(
                                          Icons.restore,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  )
                : Container();
          },
        );
      },
    );
  }
}
