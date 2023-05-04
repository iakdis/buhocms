import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.isExtended,
    required this.text,
    required this.icon,
    required this.onTap,
    this.textStyle,
    this.iconColor,
  });

  final bool isExtended;
  final String text;
  final IconData icon;
  final TextStyle? textStyle;
  final Color? iconColor;
  final Function? onTap;

  Widget _button() {
    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: isExtended
                ? const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0)
                : const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: isExtended
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32.0,
                  color: iconColor ?? Theme.of(context).colorScheme.onSecondary,
                ),
                if (isExtended)
                  Row(
                    children: [
                      const SizedBox(width: 16.0),
                      SizedBox(
                        width: constraints.maxWidth - 80,
                        child: Text(
                          text,
                          style:
                              textStyle ?? const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          onTap: () => onTap?.call(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => _button();
}
