import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/actions/review_bottom_sheet.dart';
import 'package:w_app/screens/home/comment_screen.dart';
import 'package:w_app/screens/home/widgets/images_dimension_widget.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/screens/profile/foreign_profile_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/likes_bottom_sheet_widget.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class CommentWidget extends StatelessWidget {
  final User userMain;
  final bool isThread;
  final bool isActive;
  final Comment comment;
  final VoidCallback onLike;
  final Future Function() onComment;
  final VoidCallback onFollowUser;
  final Future Function()? onDelete;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.userMain,
    this.isActive = true,
    this.isThread = false,
    required this.onComment,
    required this.onFollowUser,
    required this.onLike,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final sizeH = MediaQuery.of(context).size.height / 100;
    return GestureDetector(
      onTap: () {
        if (!isActive) return;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CommentPage(
                    comment: comment,
                    user: userMain,
                    onLike: onLike,
                    onComment: onComment,
                    onFollowUser: onFollowUser,
                    onDelete: onDelete,
                  )),
        );
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const Divider(
              height: 1,
              color: ColorStyle.grey,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      showLoadingDialog(context);
                      await ApiService()
                          .getProfileDetail(comment.user.idUser)
                          .then((value) {
                        Navigator.of(context, rootNavigator: true).pop();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ForeignProfileScreen(value)),
                        );
                      }, onError: (e) {
                        Navigator.of(context, rootNavigator: true).pop();
                        showErrorSnackBar(context, e.toString());
                      });
                    },
                    child: SizedBox(
                      width: 42,
                      child: Stack(
                        children: [
                          CircularAvatarW(
                            externalRadius: const Offset(38, 38),
                            internalRadius: const Offset(34, 34),
                            nameAvatar: comment.user.name.substring(0, 1),
                            isCompany: false,
                            sizeText: 22,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Visibility(
                              visible: userMain.idUser == comment.user.idUser
                                  ? false
                                  : !comment.user.followed,
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
                          GestureDetector(
                            onTap: () async {
                              showLoadingDialog(context);
                              await ApiService()
                                  .getProfileDetail(comment.user.idUser)
                                  .then((value) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForeignProfileScreen(value)),
                                );
                              }, onError: (e) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                showErrorSnackBar(context, e.toString());
                              });
                            },
                            child: Text(
                              "${comment.user.name} ${comment.user.lastName}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14),
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            comment.timeAgo,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: ColorStyle.grey,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
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
                            user: userMain,
                            onReport: () {},
                            actions: [
                              if (userMain.idUser != comment.user.idUser)
                                ReviewAction(
                                  text: comment.user.followed
                                      ? "Dejar de seguir a ${comment.user.name}"
                                      : "Seguir a ${comment.user.name}",
                                  onPressed: () {
                                    onFollowUser();
                                  },
                                ),
                              if (userMain.idUser == comment.user.idUser)
                                ReviewAction(
                                    color: ColorStyle.accentRed,
                                    text: "Eliminar",
                                    onPressed: () async {
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
                      visible: true, // isThread,
                      child: Container(
                        width: 1.5,
                        margin: const EdgeInsets.only(left: 34, bottom: 16),
                        color: isThread
                            ? ColorStyle.borderGrey
                            : Colors.transparent,
                      )),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(
                        //       left: 24, right: 18, bottom: 12),
                        //   child: Text(
                        //     comment.content,
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
                          padding: const EdgeInsets.only(
                              left: 24, right: 18, bottom: 12),
                          child: Linkify(
                            onOpen: (link) async {
                              if (await canLaunchUrlString(link.url)) {
                                await launchUrlString(link.url);
                              } else {
                                throw 'Could not launch $link';
                              }
                            },
                            text: comment.content,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat',
                              height: 1.42,
                              letterSpacing: 0.36,
                            ),
                            linkStyle: TextStyle(color: ColorStyle.mainBlue),
                          ),
                        ),
                        if (comment.images?.isNotEmpty ?? false)
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: comment.images!.length == 1
                                  ? sizeH * 100 * 3 / 5
                                  : 256,
                            ),
                            margin: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            height: comment.images!.length == 1 ? null : 256,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: buildDynamicLayout(
                                  comment.images ?? [], context),
                            ),
                          ),
                        Padding(
                            padding: const EdgeInsets.only(left: 24, right: 16),
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      PressTransform(
                                        onPressed: onLike,
                                        child: SvgPicture.asset(
                                          // 'assets/images/icons/like.svg',
                                          comment.isLiked
                                              ? 'assets/images/icons/likeActive.svg'
                                              : 'assets/images/icons/like.svg',
                                          width: 18,
                                          height: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      PressTransform(
                                        onPressed: onComment,
                                        child: SvgPicture.asset(
                                          'assets/images/icons/commentReview.svg',
                                          width: 18,
                                          height: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      PressTransform(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          // Construye la URL del review para compartir
                                          final String reviewUrl =
                                              'https://www.whistleblowwer.com/review/${comment.idReview}';

                                          //identificar cuando recibo el detail que el back me devuelva si es review o comment
                                          //un review puede llegar a tener el mismo id que un comment
                                          //por ahora quedara con el id review del comment para que no se dañe

                                          Share.share(reviewUrl);
                                        },
                                        child: SvgPicture.asset(
                                          'assets/images/icons/send.svg',
                                          width: 18,
                                          height: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 16, top: 8, bottom: 16),
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
                                            const Color.fromRGBO(0, 0, 0, 0.1),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                          ),
                                        ),
                                        builder: (context) =>
                                            LikesBottomSheetWidget(
                                              reviewId: comment.idReview,
                                              userMain: userMain.idUser,
                                            ));
                                  },
                                  child: Text(
                                    "${comment.likes} Me gustas",
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
                                    "${comment.getComments}",
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
            // if (comment.children != null)
            //   for (Comment childComment in comment.children!)
            //     Padding(
            //       padding: const EdgeInsets.only(left: 30),
            //       child: CommentWidget(
            //         comment: childComment,
            //         user: user,
            //         onComment: () async {},
            //         onFollowUser: () {},
            //         onLike: () {},
            //       ),
            //     ),
          ],
        ),
      ),
    );
  }
}
