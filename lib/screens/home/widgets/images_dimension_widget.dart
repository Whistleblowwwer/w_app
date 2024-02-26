import 'package:cached_network_image/cached_network_image.dart';
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
        ? CachedNetworkImage(
            imageUrl: images[index],
            fit: images.length == 1 ? BoxFit.fitWidth : BoxFit.cover,
            placeholder: (context, url) => SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: ColorStyle.grey, // Fondo del indicador
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          ColorStyle.darkPurple),
                    ),
                  ),
                ),
            errorWidget: (context, url, error) => Icon(Icons.error))
        : AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: images[index],
                  fit: images.length == 1 ? BoxFit.fitWidth : BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: ColorStyle.grey, // Fondo del indicador
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          ColorStyle.darkPurple),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error_outline_outlined),
                  ),
                ),
                Container(
                    color: (index == 3 && images.length > 4)
                        ? Colors.black.withOpacity(0.6)
                        : null,
                    child: Center(
                        child: Text(
                      (index == 3 && images.length > 4)
                          ? "+${images.length - 1 - index}"
                          : '',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 32),
                    ))),
              ],
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
  if (count >= 4) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                  child: buildAspectRatioWidget(16 / 9, 0, images, context)),
              Container(
                height: 2,
              ),
              Expanded(
                  child: buildAspectRatioWidget(16 / 9, 1, images, context)),
            ],
          ),
        ),
        const SizedBox(
          width: 2,
          height: double.maxFinite,
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                  child: buildAspectRatioWidget(16 / 9, 2, images, context)),
              Container(
                height: 2,
              ),
              Expanded(
                  child: buildAspectRatioWidget(16 / 9, 3, images, context)),
            ],
          ),
        ),
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