import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/feed_bloc/feed_state.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/screens/actions/comments_screen.dart';
import 'package:w_app/screens/add/add_review.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
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
  late UserBloc _userBloc;
  List<Review> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // futureListReview =
    //     ApiService().getBusinessReviews(widget.business.idBusiness);
    _feedBloc = BlocProvider.of<FeedBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);
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
      if (mounted) {
        showErrorSnackBar(context, e.toString());
      }

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
  }

  void _followBusiness() {
    // Update the review with the new 'like' status
    setState(() {
      widget.business.isFollowed = !widget.business.isFollowed;
      // Actualizar el estado de 'followed' del usuario en los comentarios
      reviews = reviews.map((reviewItem) {
        return reviewItem.copyWith(
            business: reviewItem.business!
                .copyWith(followed: !reviewItem.business!.followed));
      }).toList();
    });
  }

  void _updateReviewsIfChanged(List<Review> updatedReviews) {
    bool needsUpdate = false;

    // Comprobar si alguna de las reseñas en el perfil ha sido actualizada en el feed
    for (var updatedReview in updatedReviews) {
      int index =
          reviews.indexWhere((r) => r.idReview == updatedReview.idReview);
      if (index != -1 && reviews[index] != updatedReview) {
        reviews[index] = updatedReview;
        needsUpdate = true;
      }
    }

    // Si es necesario, actualizar la UI
    if (needsUpdate) {
      setState(() {});
    }
  }

  void addCommentToReview(String reviewId) {
    setState(() {
      reviews = reviews.map((review) {
        if (review.idReview == reviewId) {
          return review.copyWith(
            comments: review.comments + 1,
          );
        }
        return review;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;
    return Scaffold(
      body: BlocListener<FeedBloc, FeedState>(
        listener: (BuildContext context, state) {
          if (state is FeedLoaded) {
            // Actualizar la lista de reseñas si alguna de ellas ha cambiado en el feed
            _updateReviewsIfChanged(state.reviews);
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              top: 86,
              child: RefreshIndicator.adaptive(
                color: ColorStyle.darkPurple,
                onRefresh: () async {
                  await _loadReviews();
                  await Future.delayed(const Duration(milliseconds: 300));
                },
                child: CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 160,
                        width: double.maxFinite,
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                                        initialRating:
                                            widget.business.averageRating,
                                        glowColor: ColorStyle.lightGrey,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        unratedColor: ColorStyle.lightGrey,
                                        ignoreGestures: true,
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
                                        "  (${widget.business.averageRating.toStringAsFixed(2)})",
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
                              onPressed: () {
                                _feedBloc.add(
                                    FollowBusiness(widget.business.idBusiness));
                                _followBusiness();
                              },
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
                                      widget.business.isFollowed
                                          ? "Siguiendo"
                                          : "Seguir",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: widget.business.isFollowed
                                              ? Colors.black
                                              : ColorStyle.solidBlue,
                                          fontFamily: 'Montserrat'),
                                    ),
                                    // Icon(
                                    //   widget.business.followed
                                    //       ? FeatherIcons.userCheck
                                    //       : FeatherIcons.userPlus,
                                    //   color: ColorStyle.darkPurple,
                                    //   size: 18,
                                    // ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
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
                                  childCount: reviews
                                      .length, // número de items en la lista
                                  (BuildContext context, int index) {
                                    print(index);
                                    return ReviewCard(
                                      isActiveBusiness: false,
                                      showBusiness: false,
                                      review: reviews[index],
                                      onFollowUser: () async {
                                        _feedBloc
                                            .add(FollowUser(reviews[index]));
                                        _followUser(reviews[index]);
                                      },
                                      onFollowBusinnes: () {
                                        _feedBloc.add(FollowBusiness(
                                            widget.business.idBusiness));
                                        _followBusiness();
                                      },
                                      onLike: () {
                                        // Call the API to update the 'like' status
                                        _feedBloc
                                            .add(LikeReview(reviews[index]));
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
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(20.0),
                                                      topRight:
                                                          Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  builder: (context) =>
                                                      BackdropFilter(
                                                          filter:
                                                              ImageFilter.blur(
                                                                  sigmaX: 6,
                                                                  sigmaY: 6),
                                                          child:
                                                              CommentBottomSheet(
                                                            user:
                                                                userState.user,
                                                            name: reviews[index]
                                                                .user
                                                                .name,
                                                            lastName:
                                                                reviews[index]
                                                                    .user
                                                                    .lastName,
                                                            content:
                                                                reviews[index]
                                                                    .content,
                                                          )));

                                          if (response != null) {
                                            try {
                                              final commentResponse =
                                                  await ApiService()
                                                      .commentReview(
                                                          content: response[
                                                              'content'],
                                                          idReview:
                                                              reviews[index]
                                                                  .idReview);

                                              addCommentToReview(
                                                reviews[index].idReview,
                                              );

                                              _feedBloc.add(AddComment(
                                                  comment: commentResponse,
                                                  reviewId:
                                                      reviews[index].idReview));
                                              return 200;
                                            } catch (e) {
                                              if (mounted) {
                                                showErrorSnackBar(context,
                                                    'No se pudo agregar el comentario');
                                              }
                                            }
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                              )
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 86,
                child: Container(
                  width: sizeW * 100,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.symmetric(
                          horizontal: BorderSide(
                              color: ColorStyle.borderGrey, width: 0.5))),
                  padding:
                      EdgeInsets.only(bottom: 16, top: 16, left: 16, right: 16),
                  child: PressTransform(
                    onPressed: () async {
                      final userState = _userBloc.state;
                      if (userState is UserLoaded) {
                        await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            barrierColor: const Color.fromRGBO(0, 0, 0, 0.1),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                            builder: (context) => BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: CombinedBottomSheet(
                                  user: userState.user,
                                  business: widget.business,
                                )));

                        await _loadReviews();
                      }
                    },
                    child: Container(
                      width: double.maxFinite,
                      height: 40,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: ColorStyle.lightGrey),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Escribe una reseña a ${widget.business.name}',
                              maxLines: 1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          SvgPicture.asset(
                            'assets/images/icons/Whistle.svg',
                            width: 32,
                            height: 32,
                            colorFilter: ColorFilter.mode(
                                ColorStyle.darkPurple, BlendMode.srcIn),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            Positioned(
              top: 0,
              child: Container(
                width: sizeW * 100,
                height: Platform.isIOS ? 102 : 56,
                padding: EdgeInsets.only(bottom: 16),
                color: Colors.white,
                alignment: Alignment.bottomCenter,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PressTransform(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: Icon(FeatherIcons.arrowLeft),
                          ),
                          Text(
                            "Atrás",
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Proyecto/Empresa",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    // Positioned(
                    //   right: 16,
                    //   child: Icon(FeatherIcons.moreHorizontal),
                    // )
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
