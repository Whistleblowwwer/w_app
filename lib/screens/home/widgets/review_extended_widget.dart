import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class ReviewExtendedWidget extends StatefulWidget {
  final Review review;
  final VoidCallback onLike;
  final Future Function() onComment;
  final VoidCallback onFollowUser;

  ReviewExtendedWidget(
      {required this.review,
      required this.onLike,
      required this.onComment,
      required this.onFollowUser});

  @override
  State<ReviewExtendedWidget> createState() => _ReviewExtendedWidgetState();
}

class _ReviewExtendedWidgetState extends State<ReviewExtendedWidget> {
  late Future<List<Comment>> futureListReviewComment;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    futureListReviewComment =
        ApiService().getReviewsParentComments(widget.review.idReview);
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;
    final stateUser = BlocProvider.of<UserBloc>(context).state;

    return stateUser is UserLoaded
        ? Container(
            width: sizeW * 100,
            height: double.maxFinite,
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.only(top: 96),
                ),
                SliverToBoxAdapter(
                  child: ReviewCard(
                    isThread: true,
                    review: widget.review,
                    onComment: widget.onComment,
                    onLike: widget.onLike,
                    onFollowUser: widget.onFollowUser,
                  ),
                ),
                // ReviewIntoCard(author: review.author, content: review.content),
                FutureBuilder(
                    future: futureListReviewComment,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Comment>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 96),
                              child: Center(
                                  child: CircularProgressIndicator.adaptive()),
                            ),
                          );

                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return SliverToBoxAdapter(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 256,
                                  ),
                                  Text(
                                    '¡Ups!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    'Parece que no hay data ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 256,
                                  ),
                                  Text(
                                    '!Ups¡',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    'Parece que no hay data ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  print(index);
                                  return CommentWidget(
                                      comment: snapshot.data![index],
                                      user: stateUser.user);
                                },
                                childCount: snapshot.data!
                                    .length, // número de items en la lista
                              ),
                            );
                          }

                        default:
                          return SliverToBoxAdapter();
                      }
                    }),
                SliverPadding(
                  padding: EdgeInsets.only(top: 112),
                ),
                // for (Comment comment in []) CommentWidget(comment: comment),
              ],
            ),
          )
        : SizedBox();
  }
}

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final User user;

  const CommentWidget({required this.comment, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(
            height: 1,
            color: ColorStyle.grey,
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
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
                          visible: user.idUser == comment.idUser
                              ? false
                              : !comment.user.followed,
                          child: PressTransform(
                            onPressed: () {
                              print(user.idUser);
                              print(user.idUser == comment.user.idUser);
                            },
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    PressTransform(
                                      onPressed: () {},
                                      child: SvgPicture.asset(
                                        'assets/images/icons/like.svg',
                                        // comment.isLiked
                                        //     ? 'assets/images/icons/likeActive.svg'
                                        //     : 'assets/images/icons/like.svg',
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
                                  "${comment.children?.length ?? 0} respuestas",
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
          if (comment.children != null)
            for (var childComment in comment.children!)
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: CommentWidget(comment: childComment, user: user),
              ),
        ],
      ),
    );
  }
}
