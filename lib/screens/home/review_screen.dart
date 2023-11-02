import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/screens/home/widgets/review_extended_widget.dart';

class ReviewPage extends StatefulWidget {
  final Review review;
  const ReviewPage({super.key, required this.review});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: [
              ReviewExtendedWidget(review: widget.review),
              Container(
                width: double.maxFinite,
                height: Platform.isIOS ? 102 : 56,
                padding: EdgeInsets.only(top: 24),
                decoration: BoxDecoration(color: Colors.white),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 8),
                        child: Icon(FeatherIcons.arrowLeft),
                      ),
                      Text(
                        "Empresa",
                        style: TextStyle(fontFamily: 'Montserrat'),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
