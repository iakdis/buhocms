import 'package:buhocms/src/i18n/l10n.dart';
import 'package:buhocms/src/provider/app/ssg_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../ssg/ssg.dart';

class SSGIcon extends StatelessWidget {
  const SSGIcon({Key? key}) : super(key: key);

  Widget ssgIcon(BuildContext context) {
    final ssg = context.watch<SSGProvider>().ssg;
    final tooltip = Localization.appLocalizations()
        .currentSSG(SSG.getSSGName(SSG.getSSGType(ssg)));

    return Tooltip(
      message: tooltip,
      child: SvgPicture.asset(
        'assets/images/${SSG.getSSGName(SSG.getSSGType(ssg)).toLowerCase()}.svg',
        width: 28,
        height: 28,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onPrimary,
          BlendMode.srcIn,
        ),
        semanticsLabel: tooltip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ssgIcon(context);
}
