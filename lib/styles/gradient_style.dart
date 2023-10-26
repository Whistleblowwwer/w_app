import 'package:flutter/material.dart';

class GradientStyle {
  // Gradiente para el icono de estrella de rating
  LinearGradient ratingStarGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      tileMode: TileMode.repeated,
      colors: <Color>[Color(0xFFFFEC59), Color(0xFFFFA238)]);

  // Gradiente para el icono de Nodoo Control
  LinearGradient medicFlowGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.centerRight,
      stops: [
        0.0,
        1.0
      ],
      colors: <Color>[
        Color.fromRGBO(28, 79, 200, 1),
        Color.fromRGBO(39, 110, 241, 1),
      ]);

  // Gradiente para el icono de Nodoo Control
  LinearGradient medicFlowBlueGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [
        0.0,
        1.0
      ],
      colors: <Color>[
        Color.fromRGBO(28, 79, 200, 1),
        Color.fromRGBO(39, 110, 241, 1),
      ]);

  LinearGradient profileGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      tileMode: TileMode.repeated,
      colors: <Color>[
        Color.fromRGBO(131, 248, 255, 1),
        Color.fromRGBO(79, 113, 255, 1)
      ]);

  // Gradiente para el icono de Nodoo Control
  LinearGradient deleteGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.centerRight,
      stops: [
        0.0,
        1.0
      ],
      colors: <Color>[
        Color.fromRGBO(201, 24, 74, 1),
        Color.fromRGBO(240, 54, 87, 1),
      ]);

  // Gradiente para el fondo para las pantallas de onboarding.
  LinearGradient buttonGratient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.repeated,
      colors: <Color>[
        Color.fromRGBO(46, 204, 113, 1),
        Color.fromRGBO(46, 204, 113, 1)
      ]);
}
