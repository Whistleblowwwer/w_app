import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:w_app/models/article_model.dart';
import 'package:w_app/styles/color_style.dart';

class NoticeDetailScreen extends StatefulWidget {
  final int index;
  final Article article;
  const NoticeDetailScreen(
      {super.key, required this.index, required this.article});

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    double sizeW = MediaQuery.of(context).size.width / 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: sizeW * 100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 256,
                        width: sizeW * 100,
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: const BoxDecoration(
                            // gradient: GradientStyle().grayGradient,
                            ),
                        child: Hero(
                            tag: widget.index,
                            child: widget.article.imageUrl != null
                                ? Image.network(
                                    widget.article.imageUrl!,
                                    width: double.maxFinite,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/logos/Whistle.png',
                                    width: double.maxFinite,
                                  ))),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Text(
                        widget.article.title,
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 24),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Markdown(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          data: widget.article.content),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 24, vertical: 0),
                    //   child: Text(
                    //     widget.article.content,
                    //     style: const TextStyle(
                    //         fontFamily: 'Montserrat',
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w400),
                    //   ),
                    // ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 24, top: 16, bottom: 16),
                        child: Text(
                          widget.article.formatDate(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: ColorStyle.textGrey,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: sizeW * 100,
              height: 56,
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Icon(FeatherIcons.arrowLeft),
                    ),
                  ),
                  const Text(
                    "Noticias",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
