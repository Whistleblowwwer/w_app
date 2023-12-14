import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class RoundedDotterRectangleBorder extends StatelessWidget {
  final Color color;
  final Color? backgroundcolor;
  final double width;
  final double height;
  final double borderRadius;
  final double borderWidth; // Nuevo parámetro para el grosor del borde
  final Widget? icon;

  const RoundedDotterRectangleBorder(
      {Key? key,
      this.color = Colors.blue,
      this.width = 100.0,
      this.height = 50.0,
      this.borderRadius = 10.0,
      this.borderWidth = 2.0, // Valor por defecto para el grosor del borde
      this.icon,
      this.backgroundcolor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
                color: backgroundcolor,
                borderRadius: BorderRadius.circular(borderRadius)),
          ),
          icon ?? Container(),
          CustomPaint(
            size: Size(width, height),
            foregroundPainter: MyPainter(
              completeColor: color,
              borderRadius: borderRadius,
              borderWidth: borderWidth, // Pasar el nuevo parámetro
            ),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final Color completeColor;
  final double borderRadius;
  final double borderWidth; // Nuevo parámetro para el grosor del borde

  MyPainter({
    required this.completeColor,
    required this.borderRadius,
    required this.borderWidth, // Nuevo parámetro
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint complete = Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth; // Usar el nuevo parámetro

    double dashWidth = 8.0;
    double dashSpace = 5.0;

    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double totalLength = pathMetric.length;
      double currentLength = 0.0;

      while (currentLength < totalLength) {
        final double nextLength = min(currentLength + dashWidth, totalLength);
        final Path extractPath =
            pathMetric.extractPath(currentLength, nextLength);
        canvas.drawPath(extractPath, complete);
        currentLength = nextLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DottedCircularBorder extends StatelessWidget {
  final Color color;
  final double diameter; // Diametro del círculo
  final double borderWidth;

  final Widget? icon;

  const DottedCircularBorder({
    Key? key,
    this.color = Colors.blue,
    this.diameter = 100.0,
    this.borderWidth = 2.0,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: diameter,
      width: diameter,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          icon ?? Container(),
          CustomPaint(
            size: Size(diameter, diameter),
            foregroundPainter: CirclePainter(
              completeColor: color,
              borderWidth: borderWidth,
            ),
          ),
        ],
      ),
    );
  }
}

//

class CirclePainter extends CustomPainter {
  final Color completeColor;
  final double borderWidth;

  CirclePainter({
    required this.completeColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint complete = Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    double dashWidth = 6.0;
    double dashSpace = 6.0;

    Path path = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double totalLength = pathMetric.length;
      double currentLength = 0.0;

      while (currentLength < totalLength) {
        final double nextLength = min(currentLength + dashWidth, totalLength);
        final Path extractPath =
            pathMetric.extractPath(currentLength, nextLength);
        canvas.drawPath(extractPath, complete);
        currentLength = nextLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
