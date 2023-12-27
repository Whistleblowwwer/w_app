import 'package:flutter/material.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/styles/shadow_style.dart';

class CircularAvatarW extends StatelessWidget {
  const CircularAvatarW(
      {super.key,
      required this.externalRadius,
      required this.internalRadius,
      required this.nameAvatar,
      this.sizeText,
      required this.isCompany,
      this.sizeIcon,
      this.urlImage});

  final Offset externalRadius;
  final Offset internalRadius;
  final String nameAvatar;
  final double? sizeText;
  final double? sizeIcon;
  final bool isCompany;
  final String? urlImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: externalRadius.dy,
      width: externalRadius.dx,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [ShadowStyle().objectNormalShadow]),
      child: Container(
        alignment: Alignment.center,
        height: internalRadius.dy,
        width: internalRadius.dx,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: GradientStyle().profileGradient,
        ),
        child: isCompany
            ? Icon(
                Icons.work_rounded,
                color: Colors.white,
                size: sizeIcon ?? 20,
              )
            : urlImage != null
                ? Image.network(
                    urlImage!,
                    fit: BoxFit.cover,
                  )
                : Text(
                    nameAvatar,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: sizeText ?? 25,
                        color: Colors.white),
                  ),
      ),
    );
  }
}

String removeTildes(String texto) {
  final Map<String, String> reemplazos = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'Á': 'A',
    'É': 'E',
    'Í': 'I',
    'Ó': 'O',
    'Ú': 'U',
  };

  String textoSinTildes = '';
  for (var letra in texto.runes) {
    final char = String.fromCharCode(letra);
    textoSinTildes += reemplazos[char] ?? char;
  }
  return textoSinTildes;
}
