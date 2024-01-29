import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/screens/business_screen.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class BusinessWidget extends StatelessWidget {
  final Business business;
  final Function()? onAddReview;
  const BusinessWidget({
    super.key,
    required this.business,
    this.onAddReview,
  });

  @override
  Widget build(BuildContext context) {
    final sizeH = MediaQuery.of(context).size.height / 100;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BusinessScreen(business: business)),
        );
      },
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 8),
              child: Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            business.entity,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                                color: ColorStyle.grey,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // PressTransform(
                  //   onPressed: () {
                  //     HapticFeedback.lightImpact();
                  //   },
                  //   child: SvgPicture.asset(
                  //     'assets/images/icons/send.svg',
                  //     width: 20,
                  //     height: 20,
                  //   ),
                  // ),
                  // GestureDetector(
                  //   onTap: () async {},
                  //   child: const Icon(
                  //     FeatherIcons.moreHorizontal,
                  //     size: 18,
                  //   ),
                  // ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 16, right: 18, bottom: 4),
            //   child: Text(
            //     "Categoria: Inmobiliaria",
            //     textAlign: TextAlign.start,
            //     style: const TextStyle(
            //       fontWeight: FontWeight.w400,
            //       fontFamily: 'Montserrat',
            //       height: 1.42,
            //       letterSpacing: 0.36,
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(
                  left: 16,
                  right: 18,
                  bottom: business.joinedAt == null ? 8 : 4),
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: List.generate(
                      2,
                      (index) => Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(
                              0 == index
                                  ? FeatherIcons.briefcase
                                  : FeatherIcons.mapPin,
                              size: 16,
                              color: ColorStyle.textGrey,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              0 == index
                                  ? business.category?.name ?? ''
                                  : "${business.city}, ${business.country}",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: ColorStyle.textGrey,
                                fontFamily: 'Montserrat',
                                height: 1.42,
                                letterSpacing: 0.36,
                              ),
                            ),
                          ]))),
            ),
            business.joinedAt == null
                ? SizedBox.shrink()
                : Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 18, bottom: 8),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        FeatherIcons.calendar,
                        size: 16,
                        color: ColorStyle.textGrey,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        "${business.joinedDateFormatted}",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: ColorStyle.textGrey,
                          fontFamily: 'Montserrat',
                          height: 1.42,
                          letterSpacing: 0.36,
                        ),
                      ),
                    ]),
                  ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: SizedBox(
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        maxRating: 5,
                        itemSize: 22,
                        initialRating: business.averageRating,
                        glowColor: Colors.white,
                        minRating: 1,
                        direction: Axis.horizontal,
                        unratedColor: Colors.grey[200],
                        ignoreGestures: true,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 0.5),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: ColorStyle.solidBlue,
                        ),
                        onRatingUpdate: (rating) {
                          // setState(() {
                          //   ratingController = rating;
                          // });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PressTransform(
                            onPressed: onAddReview ?? () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                  color: ColorStyle.lightGrey,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/icons/Whistle.svg',
                                    width: 28,
                                    height: 28,
                                    colorFilter: const ColorFilter.mode(
                                        ColorStyle.darkPurple, BlendMode.srcIn),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Haz una reseña",
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: ColorStyle.midToneGrey,
                                      fontFamily: 'Montserrat',
                                      height: 1.42,
                                      letterSpacing: 0.36,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 8, bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    PressTransform(
                      onPressed: () {},
                      child: Text(
                        "${business.followers} miembros",
                        style: const TextStyle(
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
                        "${business.reviewsCount} reseñas",
                        style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              color: ColorStyle.grey,
            )
          ],
        ),
      ),
    );
  }
}
