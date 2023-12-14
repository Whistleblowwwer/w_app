import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class ImageCarousel extends StatefulWidget {
  final List<File> images;
  final int initialPage;

  const ImageCarousel(
      {super.key, required this.images, required this.initialPage});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    print("-=----");
    print(widget.images[widget.initialPage].path);
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            color: Colors.black,
            alignment: Alignment.center,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (int page) {},
              itemBuilder: (context, index) {
                return Hero(
                  tag: 1,
                  child: Image.file(
                    widget.images[index],
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 64,
            left: 16,
            child: IconButton(
              icon: const Icon(
                FeatherIcons.arrowLeft,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
