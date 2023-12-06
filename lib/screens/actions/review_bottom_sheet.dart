import 'package:flutter/material.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class ReviewBottomSheet extends StatelessWidget {
  final User user;
  final Review review;
  final VoidCallback onFollowUser;
  final VoidCallback onFollowBusinnes;
  const ReviewBottomSheet(
      {super.key,
      required this.user,
      required this.review,
      required this.onFollowUser,
      required this.onFollowBusinnes});

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    // final sizeH = MediaQuery.of(context).size.height / 100;
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 4,
                  margin: EdgeInsets.only(top: 16, bottom: 24),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: ColorStyle.borderGrey),
                ),
                OptionsWidget(options: [
                  Option(
                    text: review.business?.followed ?? false
                        ? "Dejar de seguir a ${review.business?.name ?? ''}"
                        : "Seguir a ${review.business?.name ?? ''}",
                    onPressed: () {
                      onFollowBusinnes();
                    },
                  ),
                  if (user.idUser != review.user.idUser)
                    Option(
                      isLast: true,
                      text: review.user.followed
                          ? "Dejar de seguir a ${review.user.name}"
                          : "Seguir a ${review.user.name}",
                      onPressed: () {
                        onFollowUser();
                      },
                    )
                ]),
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16, bottom: 56),
                  width: double.maxFinite,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: ColorStyle.lightGrey,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PressTransform(
                        animation: false,
                        onPressed: () {
                          print("a");
                        },
                        child: Container(
                          color: ColorStyle.lightGrey,
                          width: double.maxFinite,
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "Reportar",
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.red,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Option {
  final String text;
  final Function onPressed;
  final bool isLast; // Indica si esta opción es la última

  Option({required this.text, required this.onPressed, this.isLast = false});
}

class OptionsWidget extends StatelessWidget {
  final List<Option> options;

  const OptionsWidget({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      width: double.maxFinite,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: ColorStyle.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options
            .map((option) => Column(
                  children: [
                    PressTransform(
                      animation: false,
                      onPressed: () {
                        option.onPressed();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        color: ColorStyle.lightGrey,
                        width: double.maxFinite,
                        padding: EdgeInsets.all(16),
                        child: Text(
                          option.text,
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    if (!option
                        .isLast) // Solo añadir Divider si no es la última opción
                      Divider(
                        height: 1,
                        color: ColorStyle.borderGrey,
                      ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
