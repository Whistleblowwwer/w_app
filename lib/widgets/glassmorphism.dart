import 'dart:ui';

import 'package:flutter/material.dart';

class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blur;
  final double borderRadius;

  const GlassMorphism(
      {Key? key,
      required this.child,
      required this.opacity,
      required this.blur,
      required this.borderRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            color: Colors.white.withOpacity(opacity),
            // border: Border.all(
            //     color: Colors.white.withOpacity(opacity), width: 1.5),
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomCenter,
            //   colors: [Colors.white60, Colors.white10],
            // ),
          ),
          child: child,
        ),
      ),
    );
  }
}
