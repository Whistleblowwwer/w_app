import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
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
                padding: EdgeInsets.only(top: 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 256,
                      width: sizeW * 100,
                      padding: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                          // gradient: GradientStyle().grayGradient,
                          ),
                      child: Hero(
                          tag: widget.index,
                          child: Image.asset(
                            widget.article.imageUrl,
                            fit: BoxFit.cover,
                            width: sizeW * 100,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Text(
                        widget.article.title,
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 24),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 0),
                      child: Text(
                        widget.article.content,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 24, top: 16),
                        child: Text(
                          widget.article.formatDate(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: ColorStyle.textGrey,
                              fontFamily: 'Montserrat',
                              fontSize: 12,
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
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Icon(FeatherIcons.arrowLeft),
                    ),
                  ),
                  Text(
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
