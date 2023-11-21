import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/screens/actions/comments_screen.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/screens/home/widgets/review_extended_widget.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class BusinessScreen extends StatefulWidget {
  final Business business;
  const BusinessScreen({super.key, required this.business});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  late Future<List<Review>> futureListReview;
  late FeedBloc _feedBloc;
  List<Review> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // futureListReview =
    //     ApiService().getBusinessReviews(widget.business.idBusiness);
    _feedBloc = BlocProvider.of<FeedBloc>(context);
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      var reviewsList =
          await ApiService().getBusinessReviews(widget.business.idBusiness);
      setState(() {
        reviews = reviewsList;
        isLoading = false;
      });
    } catch (e) {
      // Handle the error or set state to show an error message
      showErrorSnackBar(context, e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  void _likeReview(Review review) {
    // Update the review with the new 'like' status
    setState(() {
      reviews = reviews
          .map((r) => r.idReview == review.idReview
              ? r.copyWith(
                  isLiked: !r.isLiked,
                  likes: r.isLiked ? r.likes - 1 : r.likes + 1)
              : r)
          .toList();
    });
    // Call the API to update the 'like' status
    _feedBloc.add(LikeReview(review));
  }

  void _followUser(Review review) {
    // Update the review with the new 'like' status
    setState(() {
      reviews = reviews
          .map((r) => r.idReview == review.idReview
              ? r.copyWith(
                  user: r.user.copyWith(followed: !r.user.followed),
                )
              : r)
          .toList();
    });
    // Call the API to update the 'like' status
    _feedBloc.add(FollowUser(review));
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;
    return Scaffold(
      body: Container(
        width: sizeW * 100,
        height: double.maxFinite,
        child: Stack(
          children: [
            CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.only(top: 102),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 132,
                    width: double.maxFinite,
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Color.fromRGBO(255, 255, 255, 0),
                          Color.fromRGBO(0, 0, 0, 0.3)
                        ])),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.business.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Montserrat'),
                              ),
                              Text(
                                widget.business.city,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontFamily: 'Montserrat'),
                              ),
                              Row(
                                children: [
                                  RatingBar.builder(
                                    maxRating: 5,
                                    itemSize: 24,
                                    initialRating: 3.5,
                                    glowColor: ColorStyle.lightGrey,

                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    unratedColor: ColorStyle.lightGrey,
                                    // ignoreGestures: true,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.symmetric(
                                        horizontal: 0.5),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: ColorStyle.solidBlue,
                                    ),
                                    onRatingUpdate: (rating) {},
                                  ),
                                  Text(
                                    "  (3.5)",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: ColorStyle.lightGrey,
                                        fontSize: 14,
                                        fontFamily: 'Montserrat'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PressTransform(
                          onPressed: () {},
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: ColorStyle.lightGrey,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Siguiendo  ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: ColorStyle.textGrey,
                                      fontFamily: 'Montserrat'),
                                ),
                                Icon(
                                  widget.business.followed
                                      ? FeatherIcons.userCheck
                                      : FeatherIcons.userPlus,
                                  color: ColorStyle.darkPurple,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // FutureBuilder(
                //     future: futureListReview,
                //     builder: (BuildContext context,
                //         AsyncSnapshot<List<Review>> snapshot) {
                //       switch (snapshot.connectionState) {
                //         case ConnectionState.waiting:
                //           return const SliverToBoxAdapter(
                //             child: Padding(
                //               padding: EdgeInsets.only(top: 96),
                //               child: Center(
                //                   child: CircularProgressIndicator.adaptive()),
                //             ),
                //           );

                //         case ConnectionState.done:
                //           if (snapshot.hasError) {
                //             return SliverToBoxAdapter(
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.start,
                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 children: [
                //                   SizedBox(
                //                     height: 256,
                //                   ),
                //                   Text(
                //                     '¡Ups!',
                //                     textAlign: TextAlign.center,
                //                     style: TextStyle(
                //                         fontFamily: "Montserrat",
                //                         fontSize: 18,
                //                         fontWeight: FontWeight.w700),
                //                   ),
                //                   SizedBox(
                //                     height: 16,
                //                   ),
                //                   Text(
                //                     'Parece que no hay data ${snapshot.error}',
                //                     textAlign: TextAlign.center,
                //                     style: TextStyle(
                //                         fontFamily: "Montserrat",
                //                         fontSize: 18,
                //                         fontWeight: FontWeight.w400),
                //                   ),
                //                 ],
                //               ),
                //             );
                //           } else if (!snapshot.hasData ||
                //               snapshot.data!.isEmpty) {
                //             return Column(
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               children: [
                //                 SizedBox(
                //                   height: 256,
                //                 ),
                //                 Text(
                //                   '!Ups¡',
                //                   textAlign: TextAlign.center,
                //                   style: TextStyle(
                //                       fontFamily: "Montserrat",
                //                       fontSize: 18,
                //                       fontWeight: FontWeight.w700),
                //                 ),
                //                 SizedBox(
                //                   height: 16,
                //                 ),
                //                 Text(
                //                   'Parece que no hay data ${snapshot.error}',
                //                   textAlign: TextAlign.center,
                //                   style: TextStyle(
                //                       fontFamily: "Montserrat",
                //                       fontSize: 18,
                //                       fontWeight: FontWeight.w400),
                //                 ),
                //               ],
                //             );
                //           } else {
                //             return SliverList(
                //               delegate: SliverChildBuilderDelegate(
                //                 (BuildContext context, int index) {
                //                   print(index);
                //                   return ReviewCard(
                //                     showBusiness: false,
                //                     review: snapshot.data![index],
                //                     onComment: () async {},
                //                     onFollowUser: () {
                //                       _feedBloc.add(
                //                           FollowUser(snapshot.data![index]));
                //                     },
                //                     onLike: () {
                //                       _feedBloc.add(
                //                           LikeReview(snapshot.data![index]));
                //                       setState(() {});
                //                     },
                //                   );
                //                 },
                //                 childCount: snapshot.data!
                //                     .length, // número de items en la lista
                //               ),
                //             );
                //           }

                //         default:
                //           return SliverToBoxAdapter();
                //       }
                //     }),

                isLoading
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 96),
                          child: Center(
                              child: CircularProgressIndicator.adaptive()),
                        ),
                      )
                    : reviews.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Padding(
                                padding: EdgeInsets.only(top: 96),
                                child: Center(
                                  child: Text(
                                    'Parece que no hay data',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                                )),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                print(index);
                                return ReviewCard(
                                  showBusiness: false,
                                  review: reviews[index],
                                  onFollowUser: () {
                                    _followUser(reviews[index]);
                                  },
                                  onLike: () {
                                    _likeReview(reviews[index]);
                                  },
                                  onComment: () async {
                                    final userBloc =
                                        BlocProvider.of<UserBloc>(context);
                                    final userState = userBloc.state;
                                    if (userState is UserLoaded) {
                                      Map<String, dynamic>? response =
                                          await showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              useRootNavigator: true,
                                              barrierColor:
                                                  const Color.fromRGBO(
                                                      0, 0, 0, 0.1),
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(20.0),
                                                  topRight:
                                                      Radius.circular(20.0),
                                                ),
                                              ),
                                              builder: (context) =>
                                                  BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 6, sigmaY: 6),
                                                      child: CommentBottomSheet(
                                                        user: userState.user,
                                                        review: reviews[index],
                                                      )));

                                      if (response != null) {
                                        _feedBloc.add(AddComment(
                                            content: response['content'],
                                            reviewId: response['idReview']));
                                      }
                                    }
                                  },
                                );
                              },
                              childCount:
                                  reviews.length, // número de items en la lista
                            ),
                          )
              ],
            ),
            Positioned(
              top: 0,
              child: Container(
                width: sizeW * 100,
                height: Platform.isIOS ? 102 : 56,
                padding: EdgeInsets.only(bottom: 16),
                color: Colors.white,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PressTransform(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Row(
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
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 16),
                      child: Icon(FeatherIcons.moreHorizontal),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
