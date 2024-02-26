import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/screens/actions/review_bottom_sheet.dart';
import 'package:w_app/screens/business_screen.dart';
import 'package:w_app/screens/home/review_screen.dart';
import 'package:w_app/screens/home/widgets/images_dimension_widget.dart';
import 'package:w_app/screens/profile/foreign_profile_screen.dart';
import 'package:w_app/screens/profile/widgets/follow_bottom_sheet_widget.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/likes_bottom_sheet_widget.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

// Expresión regular para detectar URLs
final urlRegex = RegExp(
  r'(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])',
  caseSensitive: false,
);

// Función para procesar el texto y convertir URLs en enlaces clicables
List<TextSpan> _processText(String text) {
  List<TextSpan> spans = [];
  text.splitMapJoin(
    urlRegex,
    onMatch: (Match match) {
      // Cada vez que se encuentra una URL, se agrega como enlace
      final url = match[0]!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launch(url);
          },
      ));
      return '';
    },
    onNonMatch: (String text) {
      // El texto que no es URL se agrega normalmente
      spans.add(TextSpan(text: text));
      return '';
    },
  );
  return spans;
}

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
    // final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;
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
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      showBusiness ?? false
                          ? GestureDetector(
                              onTap: () async {
                                ApiService()
                                    .getBusinessDetail(
                                        review.business!.idBusiness)
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: const BoxDecoration(),
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
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  fontFamily: 'Montserrat'),
                                            ),
                                            Text(
                                              review.business?.entity ?? '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorStyle.grey,
                                                  fontSize: 12,
                                                  fontFamily: 'Montserrat'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Icon(
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
                                      showLoadingDialog(context);
                                      await ApiService()
                                          .getProfileDetail(review.user.idUser)
                                          .then((value) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ForeignProfileScreen(value)),
                                        );
                                      }, onError: (e) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        showErrorSnackBar(
                                            context, e.toString());
                                      });
                                    },
                                    child: CircularAvatarW(
                                      externalRadius: const Offset(38, 38),
                                      internalRadius: const Offset(34, 34),
                                      nameAvatar:
                                          '${review.user.name[0].toUpperCase()}${review.user.lastName[0].toUpperCase()}',
                                      isCompany: false,
                                      sizeText: 18,
                                      urlImage: review.user.profilePictureUrl,
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
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                            child: const Icon(
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
                                        Flexible(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (isActiveBusiness) {
                                                ApiService()
                                                    .getBusinessDetail(review
                                                        .business!.idBusiness)
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
                                              '${review.business?.name ?? ''}',
                                              overflow: TextOverflow.clip,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  fontFamily: 'Montserrat'),
                                            ),
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
                                        SizedBox(
                                          width: 24,
                                        )
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        showLoadingDialog(context);
                                        await ApiService()
                                            .getProfileDetail(
                                                review.user.idUser)
                                            .then((value) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ForeignProfileScreen(
                                                        value)),
                                          );
                                        }, onError: (e) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
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
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w300,
                                              ),
                                            )
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
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
                                      onReport: () async {
                                        // ApiService()
                                        //     .reportReview(
                                        //         idReview: review.idReview)
                                        //     .then((value) {
                                        //   if (value == 200 || value == 201) {
                                        //     showSuccessSnackBar(context,
                                        //         message:
                                        //             "Se envió el reporte exitosamente");
                                        //   }
                                        // });
                                      },
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
                              child: const Icon(
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
                                  margin: const EdgeInsets.only(
                                      left: 34, bottom: 16),
                                  color: ColorStyle.borderGrey,
                                )),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 18, bottom: 16),
                                    child: Linkify(
                                      onOpen: (link) async {
                                        if (await canLaunchUrlString(
                                            link.url)) {
                                          await launchUrlString(link.url);
                                        } else {
                                          throw 'Could not launch $link';
                                        }
                                      },
                                      text: review.content,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Montserrat',
                                        height: 1.42,
                                        letterSpacing: 0.36,
                                      ),
                                      linkStyle:
                                          TextStyle(color: ColorStyle.mainBlue),
                                    ),
                                  ),
                                  if (review.images?.isNotEmpty ?? false)
                                    Container(
                                      constraints: BoxConstraints(
                                        maxHeight: review.images!.length == 1
                                            ? sizeH * 100 * 1 / 2
                                            : 256,
                                      ),
                                      margin: const EdgeInsets.only(
                                          left: 16, right: 16, bottom: 16),
                                      height: review.images!.length == 1
                                          ? null
                                          : 256,
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: ColorStyle.grey
                                                  .withOpacity(0.3))),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: buildDynamicLayout(
                                            review.images ?? [], context),
                                      ),
                                    ),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
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
                                                const SizedBox(
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
                                                const SizedBox(
                                                  width: 16,
                                                ),
                                                PressTransform(
                                                  onPressed: () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    // Construye la URL del review para compartir
                                                    final String reviewUrl =
                                                        'https://www.whistleblowwer.com/review/${review.idReview}';

                                                    Share.share(reviewUrl);
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
                                              itemBuilder: (context, _) =>
                                                  const Icon(
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
                                    padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 8,
                                        bottom: 16),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          PressTransform(
                                            onPressed: () async {
                                              await showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  useRootNavigator: true,
                                                  barrierColor:
                                                      const Color.fromRGBO(
                                                          0, 0, 0, 0.1),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(20.0),
                                                      topRight:
                                                          Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  builder: (context) =>
                                                      LikesBottomSheetWidget(
                                                        id: review.idReview,
                                                        postType:
                                                            PostType.review,
                                                        userMain: stateUser
                                                            .user.idUser,
                                                      ));
                                            },
                                            child: Text(
                                              review.getLikes,
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
                                            onPressed: () {
                                              if (isActive) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReviewPage(
                                                            review: review,
                                                            onLike: onLike,
                                                            onComment:
                                                                onComment,
                                                            onFollowUser:
                                                                onFollowUser,
                                                            onFollowBusiness:
                                                                onFollowBusinnes,
                                                            onDelete: onDelete,
                                                          )),
                                                );
                                              }
                                            },
                                            child: Text(
                                              "${review.getComments}",
                                              style: const TextStyle(
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
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !isThread,
                child: const Divider(
                  height: 1,
                  color: ColorStyle.grey,
                ),
              )
            ],
          )
        : const SizedBox();
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Impide que se cierre el diálogo al tocar fuera
    builder: (BuildContext context) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          // decoration: BoxDecoration(
          //   shape: BoxShape.rectangle,
          //   borderRadius: BorderRadius.circular(10),
          // ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorStyle.darkPurple),
              ),
              SizedBox(height: 15),
              // Text("Cargando...",
              //     style: TextStyle(
              //         fontSize: 16,
              //         fontFamily: 'Montserrat',
              //         color: Colors.white)),
            ],
          ),
        ),
      );
    },
  );
}
