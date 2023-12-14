import 'package:flutter/material.dart';

Widget buildAspectRatioWidget(double aspectRatio, String urlImage) {
  return AspectRatio(
      aspectRatio: aspectRatio,
      child: Image.network(
        urlImage,
        fit: BoxFit.cover,
      ));
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
