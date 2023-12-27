import 'package:flutter/material.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/image_expanded.dart';

Widget buildAspectRatioWidget(
  double aspectRatio,
  int index,
  List<String> images,
  BuildContext context,
) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) =>
              ImageCarousel(images: images, initialPage: index),
        ),
      );
    },
    child: images.length == 1
        ? Image.network(
            images[index],
            fit: images.length == 1 ? BoxFit.fitWidth : BoxFit.cover,
            // Manejador de carga
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child; // Imagen cargada
              return SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: ColorStyle.grey, // Fondo del indicador
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        ColorStyle.darkPurple),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            // Manejador de errores
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
              // Aquí puedes agregar lógica adicional si necesitas manejar diferentes tipos de errores de manera diferente
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Icon(Icons.error_outline_outlined),
                ),
              );
            },
          )
        : AspectRatio(
            aspectRatio: aspectRatio,
            child: Image.network(
              images[index],
              fit: images.length == 1 ? BoxFit.fitWidth : BoxFit.cover,
              // Manejador de carga
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child; // Imagen cargada
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: ColorStyle.grey, // Fondo del indicador
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        ColorStyle.darkPurple),
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
                return const Center(
                  child: Icon(Icons.error_outline_outlined),
                );
              },
            ),
          ),
  );
}

Widget buildDynamicLayout(List<String> images, BuildContext context) {
  int count = images.length;

  if (count == 1) {
    return buildAspectRatioWidget(16 / 9, 0, images, context);
  }

  if (count == 2) {
    return Row(children: [
      Expanded(
          child: buildAspectRatioWidget(
        9 / 16,
        0,
        images,
        context,
      )),
      const SizedBox(
        width: 2,
        height: double.maxFinite,
      ),
      Expanded(
          child: buildAspectRatioWidget(
        9 / 16,
        1,
        images,
        context,
      )),
    ]);
  }

  if (count == 3) {
    return Row(
      children: [
        Expanded(child: buildAspectRatioWidget(9 / 16, 0, images, context)),
        const SizedBox(
          width: 2,
          height: double.maxFinite,
        ),
        Column(
          children: [
            Expanded(child: buildAspectRatioWidget(4 / 3, 1, images, context)),
            Container(
              height: 2,
            ),
            Expanded(child: buildAspectRatioWidget(4 / 3, 2, images, context)),
          ],
        ),
        // Column(
        //   children: List.generate(
        //     2,
        //     (index) => Expanded(
        //         child:
        //             buildAspectRatioWidget(16 / 9, index + 1, images, context)),
        //   ),
        // ),
      ],
    );
  }

  return Container(); // Caso por defecto
}

// adding(
//             padding: EdgeInsets.only(
//                 bottom: images.length == 3
//                     ? index == 1
//                         ? 2
//                         : 0
//                     : 0),