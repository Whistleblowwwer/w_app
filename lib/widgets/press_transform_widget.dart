import 'package:flutter/material.dart';

class PressTransform extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool? animation;

  const PressTransform({
    Key? key,
    required this.child,
    required this.onPressed,
    this.animation = true, // default value set to true
  }) : super(key: key);

  @override
  _PressTransformState createState() => _PressTransformState();
}

class _PressTransformState extends State<PressTransform> {
  bool _isPressed = false;

  void _updatePressedState(bool isPressed) {
    if (_isPressed != isPressed) {
      setState(() {
        _isPressed = isPressed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = _isPressed ? 0.94 : 1.0;
    final opacity = _isPressed ? 0.8 : 1.0;
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..scale(scaleFactor);

    return GestureDetector(
      onTapDown: (_) => _updatePressedState(true),
      onTapUp: (_) => _updatePressedState(false),
      onTapCancel: () => _updatePressedState(false),
      onTap: widget.onPressed,
      child: Transform(
        alignment: Alignment.center,
        transform: widget.animation! ? matrix : Matrix4.identity(),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100), // const added
          opacity: opacity,
          child: widget.child,
        ),
      ),
    );
  }
}
