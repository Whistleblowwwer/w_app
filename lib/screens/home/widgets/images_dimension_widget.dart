import 'package:flutter/material.dart';

Widget buildAspectRatioWidget(double aspectRatio, String urlImage) {
  return AspectRatio(
    aspectRatio: aspectRatio,
    child: Image.network(
      urlImage,
      headers: {'token': 'asa'},
      fit: BoxFit.cover,
      // Manejador de carga
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child; // Imagen cargada
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      // Manejador de errores
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        // Aquí puedes agregar lógica adicional si necesitas manejar diferentes tipos de errores de manera diferente
        return Image.asset("assets/images/ilustrations/Banner 1 - W.jpg");
      },
    ),
  );
}

Widget buildDynamicLayout(List<String> images, BuildContext context) {
  int count = images.length;

  if (count == 1) {
    return buildAspectRatioWidget(16 / 9, images.first);
  }

  if (count == 2) {
    return Row(
      children: List.generate(
        2,
        (index) =>
            Expanded(child: buildAspectRatioWidget(9 / 16, images[index])),
      ),
    );
  }

  if (count == 3) {
    return Row(
      children: [
        Expanded(child: buildAspectRatioWidget(9 / 16, images.first)),
        Column(
          children: List.generate(
            2,
            (index) => Expanded(
                child: buildAspectRatioWidget(16 / 9, images[index + 1])),
          ),
        ),
      ],
    );
  }

  return Container(); // Caso por defecto
}
