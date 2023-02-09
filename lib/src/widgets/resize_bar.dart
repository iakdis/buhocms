import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResizeBar extends StatefulWidget {
  const ResizeBar({
    Key? key,
    required this.onDrag,
    required this.onEnd,
    required this.maxHeight,
  }) : super(key: key);

  final Function onDrag;
  final Function onEnd;
  final double maxHeight;

  @override
  _ResizeBarState createState() => _ResizeBarState();
}

class _ResizeBarState extends State<ResizeBar> {
  late double initX;
  late double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  _handleEnd(details) {
    widget.onEnd();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        onPanStart: _handleDrag,
        onPanUpdate: _handleUpdate,
        onPanEnd: _handleEnd,
        child: Container(
          width: 15,
          height: widget.maxHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            //shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('initX', initX));
  }
}
