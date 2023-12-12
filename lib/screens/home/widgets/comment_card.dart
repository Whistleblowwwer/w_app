import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/home/comment_screen.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class CommentWidget extends StatelessWidget {
  final User user;
  final Comment comment;
  final VoidCallback onLike;
  final Future Function() onComment;
  final VoidCallback onFollowUser;

  const CommentWidget(
      {super.key,
      required this.comment,
      required this.user,
      required this.onComment,
      required this.onFollowUser,
      required this.onLike});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CommentPage(
                    comment: comment,
                    user: user,
                    onLike: onLike,
                    onComment: onComment,
                    onFollowUser: onFollowUser,
                  )),
        );
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Divider(
              height: 1,
              color: ColorStyle.grey,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Stack(
                      children: [
                        CircularAvatarW(
                          externalRadius: Offset(38, 38),
                          internalRadius: Offset(34, 34),
                          nameAvatar: comment.user.name.substring(0, 1),
                          isCompany: false,
                          sizeText: 22,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Visibility(
                            visible: user.idUser == comment.user.idUser
                                ? false
                                : !comment.user.followed,
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
                          Text(
                            "${comment.user.name} ${comment.user.lastName}",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                fontSize: 14),
                          ),
                          SizedBox(
                            height: 1,
                          ),
                          Text(
                            comment.timeAgo,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: ColorStyle.grey,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    FeatherIcons.moreHorizontal,
                    size: 18,
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
                      visible: true,
                      child: Container(
                          width: 1.5,
                          margin: EdgeInsets.only(left: 46.5, bottom: 0),
                          color: null //ColorStyle.borderGrey,
                          )),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 16, right: 18, bottom: 12),
                          child: Text(
                            comment.content,
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
                                      SizedBox(
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
                                      SizedBox(
                                        width: 16,
                                      ),
                                      PressTransform(
                                        onPressed: () {},
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
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 8, bottom: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                PressTransform(
                                  onPressed: () {},
                                  child: Text(
                                    "${comment.likes} Me gustas",
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
                                    "${comment.comments} respuestas",
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
