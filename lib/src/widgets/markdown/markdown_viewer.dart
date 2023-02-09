import 'package:buhocms/src/provider/editing/editing_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownViewer extends StatelessWidget {
  const MarkdownViewer({super.key});

  Future<void> linkOnTapHandler(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) async {
    var url = Uri.parse(href ?? '#');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditingProvider>(
      builder: (context, markdownViewerProvider, _) {
        return Markdown(
          shrinkWrap: true,
          selectable: true,
          data: markdownViewerProvider.markdownViewerText,
          onTapLink: (String text, String? href, String title) =>
              linkOnTapHandler(context, text, href, title),
        );
      },
    );
  }
}
