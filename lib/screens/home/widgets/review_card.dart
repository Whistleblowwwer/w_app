import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/screens/business_screen.dart';
import 'package:w_app/screens/home/review_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class ReviewCard extends StatefulWidget {
  final bool? showBusiness;
  final bool isThread;
  final Review review;
  const ReviewCard(
      {super.key,
      this.showBusiness,
      this.isThread = false,
      required this.review});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  double ratingController = 0.0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReviewPage(
                        review: widget.review,
                      )),
            );

            // Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => FullScreenPage()));
          },
          child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                widget.showBusiness ?? true
                    ? GestureDetector(
                        onTap: () async {
                          ApiService()
                              .getBusinessDetail(widget.review.idBusiness)
                              .then((value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BusinessScreen(
                                        business: value,
                                      )),
                            );
                          }, onError: (e) {
                            showErrorSnackBar(
                                context, 'Error: ${e.toString()}');
                          });
                        },
                        child: Container(
                          height: 56,
                          width: double.maxFinite,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration:
                              BoxDecoration(color: ColorStyle().lightGrey),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularAvatarW(
                                externalRadius: Offset(42, 42),
                                internalRadius: Offset(36, 36),
                                nameAvatar:
                                    widget.review.nameBusiness.substring(0, 1),
                                isCompany: true,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Flexible(
                                child: SizedBox(
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.review.nameBusiness,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      Text(
                                        widget.review.entity,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: ColorStyle().grey,
                                            fontSize: 12,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Icon(
                                FeatherIcons.arrowRightCircle,
                                color: ColorStyle().solidBlue,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      CircularAvatarW(
                        externalRadius: Offset(42, 42),
                        internalRadius: Offset(36, 36),
                        nameAvatar: widget.review.namePerson.substring(0, 1),
                        isCompany: false,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.review.namePerson} ${widget.review.lastName}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14),
                              ),
                              Text(
                                "4h",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: ColorStyle().grey,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PressTransform(
                        onPressed: () {},
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: ColorStyle().lightGrey,
                          ),
                          child: Icon(FeatherIcons.userCheck),
                        ),
                      )
                    ],
                  ),
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.isThread
                          ? Container(
                              width: 1,
                              margin: EdgeInsets.only(left: 36, bottom: 16),
                              color: ColorStyle().borderGrey,
                            )
                          : SizedBox(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 16, right: 18, bottom: 16),
                              child: Text(
                                widget.review.content,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  height: 1.42,
                                  letterSpacing: 0.36,
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: SizedBox(
                                  width: double.maxFinite,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          PressTransform(
                                            onPressed: () {},
                                            child: SvgPicture.asset(
                                              'assets/images/icons/like.svg',
                                              width: 22,
                                              height: 22,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          PressTransform(
                                            onPressed: () {},
                                            child: SvgPicture.asset(
                                              'assets/images/icons/commentReview.svg',
                                              width: 22,
                                              height: 22,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          PressTransform(
                                            onPressed: () {},
                                            child: SvgPicture.asset(
                                              'assets/images/icons/send.svg',
                                              width: 22,
                                              height: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                      RatingBar.builder(
                                        maxRating: 5,
                                        itemSize: 24,
                                        initialRating: 0,
                                        glowColor: Colors.white,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        unratedColor: Colors.grey[200],
                                        ignoreGestures: true,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 0.5),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: ColorStyle().solidBlue,
                                        ),
                                        onRatingUpdate: (rating) {
                                          setState(() {
                                            ratingController = rating;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 16, bottom: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    PressTransform(
                                      onPressed: () {},
                                      child: Text(
                                        "123 me gustas",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ),
                                    const Text(
                                      "  •  ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontFamily: 'Montserrat'),
                                    ),
                                    PressTransform(
                                      onPressed: () {},
                                      child: Text(
                                        "70 comentarios",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          color: ColorStyle().grey,
        )
      ],
    );
  }
}

//

class ReviewCardDefault extends StatefulWidget {
  final bool? showBusiness;
  final bool isThread;
  final Review review;
  const ReviewCardDefault(
      {super.key,
      this.showBusiness,
      this.isThread = false,
      required this.review});

  @override
  State<ReviewCardDefault> createState() => _ReviewCardDefaultState();
}

class _ReviewCardDefaultState extends State<ReviewCardDefault> {
  double ratingController = 0.0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => FullScreenPage()));
          },
          child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                widget.showBusiness ?? true
                    ? GestureDetector(
                        onTap: () async {},
                        child: Container(
                          height: 56,
                          width: double.maxFinite,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration:
                              BoxDecoration(color: ColorStyle().lightGrey),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularAvatarW(
                                externalRadius: Offset(42, 42),
                                internalRadius: Offset(36, 36),
                                nameAvatar:
                                    widget.review.nameBusiness.substring(0, 1),
                                isCompany: true,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Flexible(
                                child: SizedBox(
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.review.nameBusiness,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      Text(
                                        widget.review.entity,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: ColorStyle().grey,
                                            fontSize: 12,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Icon(
                                FeatherIcons.arrowRightCircle,
                                color: ColorStyle().solidBlue,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      CircularAvatarW(
                        externalRadius: Offset(42, 42),
                        internalRadius: Offset(36, 36),
                        nameAvatar: widget.review.namePerson.substring(0, 1),
                        isCompany: false,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.review.namePerson} ${widget.review.lastName}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14),
                              ),
                              Text(
                                "4h",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: ColorStyle().grey,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PressTransform(
                        onPressed: () {},
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: ColorStyle().lightGrey,
                          ),
                          child: Icon(FeatherIcons.userCheck),
                        ),
                      )
                    ],
                  ),
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.isThread
                          ? Container(
                              width: 1,
                              margin: EdgeInsets.only(left: 36, bottom: 16),
                              color: ColorStyle().borderGrey,
                            )
                          : SizedBox(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 16, right: 18, bottom: 16),
                              child: Text(
                                widget.review.content,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  height: 1.42,
                                  letterSpacing: 0.36,
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: SizedBox(
                                  width: double.maxFinite,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          PressTransform(
                                            onPressed: () {},
                                            child: SvgPicture.asset(
                                              'assets/images/icons/like.svg',
                                              width: 22,
                                              height: 22,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          PressTransform(
                                            onPressed: () {},
                                            child: SvgPicture.asset(
                                              'assets/images/icons/commentReview.svg',
                                              width: 22,
                                              height: 22,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          PressTransform(
                                            onPressed: () {},
                                            child: SvgPicture.asset(
                                              'assets/images/icons/send.svg',
                                              width: 22,
                                              height: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                      RatingBar.builder(
                                        maxRating: 5,
                                        itemSize: 24,
                                        initialRating: 0,
                                        glowColor: Colors.white,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        unratedColor: Colors.grey[200],
                                        ignoreGestures: true,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 0.5),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: ColorStyle().solidBlue,
                                        ),
                                        onRatingUpdate: (rating) {
                                          setState(() {
                                            ratingController = rating;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 16, bottom: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    PressTransform(
                                      onPressed: () {},
                                      child: Text(
                                        "123 me gustas",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ),
                                    const Text(
                                      "  •  ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontFamily: 'Montserrat'),
                                    ),
                                    PressTransform(
                                      onPressed: () {},
                                      child: Text(
                                        "70 comentarios",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          color: ColorStyle().grey,
        )
      ],
    );
  }
}
