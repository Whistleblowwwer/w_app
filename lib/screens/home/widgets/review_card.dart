import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:w_app/screens/home/review_screen.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';

class ReviewCard extends StatefulWidget {
  const ReviewCard({
    super.key,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  double ratingController = 0.0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(color: Colors.white),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReviewPage()),
              );
              // Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => FullScreenPage()));
            },
            child: Column(
              children: [
                Container(
                  height: 56,
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: ColorStyle().lightGrey),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularAvatarW(
                        externalRadius: Offset(42, 42),
                        internalRadius: Offset(36, 36),
                        nameAvatar: "S",
                        isCompany: true,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Starbucks",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    fontFamily: 'Montserrat'),
                              ),
                              Text(
                                "Alsea",
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      CircularAvatarW(
                        externalRadius: Offset(42, 42),
                        internalRadius: Offset(36, 36),
                        nameAvatar: "J",
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
                                "Jorge Ancer",
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
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: ColorStyle().lightGrey,
                        ),
                        child: Icon(FeatherIcons.userCheck),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 18, right: 18, bottom: 16),
                  child: Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.",
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/icons/commentReview.svg',
                                width: 22,
                                height: 22,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              SvgPicture.asset(
                                'assets/images/icons/like.svg',
                                width: 22,
                                height: 22,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              SvgPicture.asset(
                                'assets/images/icons/send.svg',
                                width: 22,
                                height: 22,
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
                            // ignoreGestures: true,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 0.5),
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
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "123 me gustas • 70 comentarios",
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
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
