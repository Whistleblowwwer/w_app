import 'package:flutter/material.dart';

class PressTransform extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const PressTransform({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  _PressTransformState createState() => _PressTransformState();
}

class _PressTransformState extends State<PressTransform> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scaleFactor = _isPressed ? 0.94 : 1.0;
    final opacity = _isPressed ? 0.8 : 1.0;
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..scale(scaleFactor);

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: widget.onPressed,
      child: Transform(
        alignment: Alignment.center,
        transform: matrix,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: opacity,
          child: widget.child,
        ),
      ),
    );
  }
}
