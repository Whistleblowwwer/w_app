import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/actions/comments_screen.dart';
import 'package:w_app/screens/actions/review_bottom_sheet.dart';
import 'package:w_app/screens/business_screen.dart';
import 'package:w_app/screens/home/review_screen.dart';
import 'package:w_app/screens/profile/foreign_profile_screen.dart';
import 'package:w_app/screens/profile/profile_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class ReviewCard extends StatelessWidget {
  final bool isActive;
  final bool isActiveBusiness;

  final bool? showBusiness;
  final bool isThread;
  final Review review;
  final VoidCallback onLike;
  final Future Function() onComment;
  final VoidCallback onFollowUser;
  final VoidCallback onFollowBusinnes;
  final VoidCallback? onDelete;

  const ReviewCard(
      {Key? key,
      this.showBusiness,
      this.isThread = false,
      this.isActive = true,
      this.isActiveBusiness = true,
      required this.review,
      required this.onComment,
      required this.onLike,
      required this.onFollowUser,
      this.onDelete,
      required this.onFollowBusinnes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stateUser = BlocProvider.of<UserBloc>(context).state;
    return stateUser is UserLoaded
        ? Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (isActive) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReviewPage(
                                review: review,
                                onLike: onLike,
                                onComment: onComment,
                                onFollowUser: onFollowUser,
                                onFollowBusiness: onFollowBusinnes,
                                onDelete: onDelete,
                              )),
                    );
                  }

                  // Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => FullScreenPage()));
                },
                child: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      false //  showBusiness ?? true
                          ? GestureDetector(
                              onTap: () async {
                                ApiService()
                                    .getBusinessDetail(review.idBusiness)
                                    .then((value) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BusinessScreen(
                                              business: value,
                                            )),
                                  );
                                }, onError: (e) {
                                  showErrorSnackBar(context, e.toString());
                                });
                              },
                              child: Container(
                                height: 56,
                                width: double.maxFinite,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: SizedBox(
                                        width: double.maxFinite,
                                        height: double.maxFinite,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              review.business?.name ?? '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  fontFamily: 'Montserrat'),
                                            ),
                                            Text(
                                              review.business?.entity ?? '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorStyle.grey,
                                                  fontSize: 12,
                                                  fontFamily: 'Montserrat'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      FeatherIcons.arrowRightCircle,
                                      color: ColorStyle.solidBlue,
                                      size: 18,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 42,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await ApiService()
                                          .getProfileDetail(review.user.idUser)
                                          .then((value) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ForeignProfileScreen(value)),
                                        );
                                      }, onError: (e) {
                                        showErrorSnackBar(
                                            context, e.toString());
                                      });
                                    },
                                    child: CircularAvatarW(
                                      externalRadius: Offset(38, 38),
                                      internalRadius: Offset(34, 34),
                                      nameAvatar:
                                          '${review.user.name.substring(0, 1).toUpperCase()}${review.user.lastName.substring(0, 1).toUpperCase()}',
                                      isCompany: false,
                                      sizeText: 18,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Visibility(
                                      visible: stateUser.user.idUser ==
                                              review.user.idUser
                                          ? false
                                          : !review.user.followed,
                                      child: PressTransform(
                                        onPressed: onFollowUser,
                                        child: Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                            child: Icon(
                                              Icons.add_circle_rounded,
                                              size: 18,
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: SizedBox(
                                width: double.maxFinite,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (isActiveBusiness) {
                                              ApiService()
                                                  .getBusinessDetail(
                                                      review.idBusiness)
                                                  .then((value) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          BusinessScreen(
                                                            business: value,
                                                          )),
                                                );
                                              }, onError: (e) {
                                                showErrorSnackBar(
                                                    context, e.toString());
                                              });
                                            }
                                          },
                                          child: Text(
                                            review.business?.name ?? '',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                fontFamily: 'Montserrat'),
                                          ),
                                        ),
                                        Visibility(
                                          visible: showBusiness ?? true
                                              ? !review.business!.followed
                                              : false,
                                          child: PressTransform(
                                            onPressed: onFollowBusinnes,
                                            child: const Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: ' • ',
                                                  ),
                                                  TextSpan(
                                                    text: 'Unirte',
                                                    style: TextStyle(
                                                      color:
                                                          ColorStyle.solidBlue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Montserrat',
                                                  color: ColorStyle.textGrey,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await ApiService()
                                            .getProfileDetail(
                                                review.user.idUser)
                                            .then((value) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ForeignProfileScreen(
                                                        value)),
                                          );
                                        }, onError: (e) {
                                          showErrorSnackBar(
                                              context, e.toString());
                                        });
                                      },
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "@${review.user.userName} • ",
                                            ),
                                            TextSpan(
                                              text: review.timeAgo,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                              ),
                                            )
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Montserrat',
                                            color: ColorStyle.textGrey,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PressTransform(
                              onPressed: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  useRootNavigator: true,
                                  isScrollControlled:
                                      true, // Permite que el contenido sea desplazable si es necesario
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  builder: (BuildContext context) {
                                    return ReviewBottomSheet(
                                      user: stateUser.user,
                                      review: review,
                                      actions: [
                                        ReviewAction(
                                          text: review.business?.followed ??
                                                  false
                                              ? "Dejar de seguir a ${review.business?.name ?? ''}"
                                              : "Seguir a ${review.business?.name ?? ''}",
                                          onPressed: () {
                                            onFollowBusinnes();
                                          },
                                        ),
                                        if (stateUser.user.idUser !=
                                            review.user.idUser)
                                          ReviewAction(
                                            text: review.user.followed
                                                ? "Dejar de seguir a ${review.user.name}"
                                                : "Seguir a ${review.user.name}",
                                            onPressed: () {
                                              onFollowUser();
                                            },
                                          ),
                                        if (stateUser.user.idUser ==
                                            review.user.idUser)
                                          ReviewAction(
                                              color: ColorStyle.accentRed,
                                              text: "Eliminar",
                                              onPressed: () {
                                                onDelete?.call();
                                              }),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Icon(
                                FeatherIcons.moreHorizontal,
                                size: 18,
                              ),
                            )
                            // PressTransform(
                            //   onPressed: () {},
                            //   child: Container(
                            //     padding:
                            //         EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(20),
                            //       color: ColorStyle.lightGrey,
                            //     ),
                            //     child: Icon(FeatherIcons.userCheck),
                            //   ),
                            // )
                          ],
                        ),
                      ),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                                visible: isThread,
                                child: Container(
                                  width: 1.5,
                                  margin: EdgeInsets.only(left: 36, bottom: 16),
                                  color: ColorStyle.borderGrey,
                                )),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 16, right: 18, bottom: 16),
                                    child: Text(
                                      review.content,
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
                                      padding:
                                          EdgeInsets.only(left: 16, right: 16),
                                      child: SizedBox(
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                PressTransform(
                                                  onPressed: () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    onLike();
                                                  },
                                                  child: SvgPicture.asset(
                                                    review.isLiked
                                                        ? 'assets/images/icons/likeActive.svg'
                                                        : 'assets/images/icons/like.svg',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 16,
                                                ),

                                                PressTransform(
                                                  onPressed: () async {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    await onComment();
                                                  },
                                                  child: SvgPicture.asset(
                                                    'assets/images/icons/commentReview.svg',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ),
                                                //                                             Flexible(

                                                SizedBox(
                                                  width: 16,
                                                ),
                                                PressTransform(
                                                  onPressed: () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                  },
                                                  child: SvgPicture.asset(
                                                    'assets/images/icons/send.svg',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            RatingBar.builder(
                                              maxRating: 5,
                                              itemSize: 22,
                                              initialRating: review.rating,
                                              glowColor: Colors.white,
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              unratedColor: Colors.grey[200],
                                              ignoreGestures: true,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 0.5),
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: ColorStyle.solidBlue,
                                              ),
                                              onRatingUpdate: (rating) {
                                                // setState(() {
                                                //   ratingController = rating;
                                                // });
                                              },
                                            ),
                                          ],
                                        ),
                                      )),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 16,
                                        bottom: 16),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          PressTransform(
                                            onPressed: () {},
                                            child: Text(
                                              review.getLikes,
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
                                              "${review.comments} respuestas",
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
              Visibility(
                visible: !isThread,
                child: Divider(
                  height: 1,
                  color: ColorStyle.grey,
                ),
              )
            ],
          )
        : SizedBox();
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
                              BoxDecoration(color: ColorStyle.lightGrey),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularAvatarW(
                                externalRadius: Offset(42, 42),
                                internalRadius: Offset(36, 36),
                                nameAvatar: widget.review.business?.name
                                        .substring(0, 1) ??
                                    '',
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
                                        widget.review.business?.name ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      Text(
                                        widget.review.business?.entity ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: ColorStyle.grey,
                                            fontSize: 12,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Icon(
                                FeatherIcons.arrowRightCircle,
                                color: ColorStyle.solidBlue,
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
                        nameAvatar: widget.review.user.name.substring(0, 1),
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
                                "${widget.review.user.name} ${widget.review.user.lastName}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14),
                              ),
                              Text(
                                "4h",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: ColorStyle.grey,
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
                            color: ColorStyle.lightGrey,
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
                              color: ColorStyle.borderGrey,
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
                                          const SizedBox(
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
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          PressTransform(
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                            },
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
                                        initialRating: widget.review.rating,
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
                                          color: ColorStyle.solidBlue,
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
          color: ColorStyle.grey,
        )
      ],
    );
  }
}


  //   child: TextField(
                                                //     controller: controllerReview,

                                                //     maxLines: 8,
                                                //     minLines: 1,

                                                //     style: const TextStyle(
                                                //         fontWeight: FontWeight.w400,
                                                //         fontSize: 14,
                                                //         fontFamily: 'Montserrat'),
                                                //     decoration: InputDecoration(
                                                //       hintText: 'Escribe algo...',
                                                //       contentPadding: const EdgeInsets.only(bottom: 16),
                                                //       border: OutlineInputBorder(
                                                //         borderRadius: BorderRadius.circular(12.0),
                                                //         borderSide: BorderSide.none,
                                                //       ),
                                                //       filled: true,
                                                //       fillColor: Colors.grey[100],
                                                //     ),
                                                //   ),
                                                // ),