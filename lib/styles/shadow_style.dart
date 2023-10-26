import 'package:flutter/material.dart';

class ShadowStyle {
  // Sombra base para un coomponente (Box)
  BoxShadow baseComponentShadow = const BoxShadow(
      color: Color.fromRGBO(26, 26, 51, 0.102),
      offset: Offset(5, 5),
      blurRadius: 11,
      spreadRadius: 0);

  // Sombra base para un post (Box)
  BoxShadow postComponentShadow = const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.25),
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: 0);

  // Sombra para objetos dentro de un componente base
  BoxShadow insideObjectShadow = const BoxShadow(
      color: Color(0x18161616),
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: -1);

  // Sombra para botón verde
  BoxShadow greenCtaShadow = const BoxShadow(
    color: Color(0x3C00FAAB),
    offset: Offset(5, 5),
    blurRadius: 20,
    spreadRadius: 5,
  );
  BoxShadow objectNormalShadow = const BoxShadow(
    color: Color.fromRGBO(22, 22, 22, 0.15),
    offset: Offset(0, 4),
    blurRadius: 20,
    spreadRadius: 0,
  );

  BoxShadow greenOutShadow = const BoxShadow(
      color: Color(0x3C00FAAB), blurRadius: 20, blurStyle: BlurStyle.outer);
}
