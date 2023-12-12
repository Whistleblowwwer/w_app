import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/feed_bloc/feed_state.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/actions/comments_screen.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/showAdaptiveDialog.dart';
import 'package:w_app/widgets/snackbar.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen(this.user);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Review>> futureListReview;
  List<Review> reviews = [];
  bool isLoading = true;
  late AuthBloc authBloc;
  late FeedBloc feedBloc;
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    feedBloc = BlocProvider.of<FeedBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      var reviewsList = await ApiService().getUserReviews(widget.user.idUser);
      if (mounted) {
        setState(() {
          reviews = reviewsList;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle the error or set state to show an error message
      showErrorSnackBar(context, e.toString());
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
    feedBloc.add(LikeReview(review));
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
    feedBloc.add(FollowUser(review));
  }

  void _followBusiness(Review review) {
    // Update the review with the new 'like' status
    setState(() {
      reviews = reviews
          .map((r) => r.idReview == review.idReview
              ? r.copyWith(
                  business:
                      r.business!.copyWith(followed: !r.business!.followed),
                )
              : r)
          .toList();
    });
    feedBloc.add(FollowBusiness(review.idBusiness));
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

  void deleteReview(String reviewId) {
    // Filtramos las reseñas para excluir la que queremos eliminar
    reviews = reviews.where((review) => review.idReview != reviewId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;

    return BlocListener<FeedBloc, FeedState>(
      listener: (BuildContext context, state) {
        if (state is FeedLoaded) {
          // Actualizar la lista de reseñas si alguna de ellas ha cambiado en el feed
          _updateReviewsIfChanged(state.reviews);
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: sizeW * 100,
                height: 102,
                padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                color: Colors.white,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.user.name} ${widget.user.lastName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Montserrat'),
                    ),
                    PressTransform(
                        onPressed: () {
                          showAdaptiveDialogIos(
                              context: context,
                              title: 'Advertencia',
                              content: '¿Seguro deseas cerrar sesión?',
                              onTapCancel: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              onTapOk: () async {
                                authBloc.add(LogOutUser());
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                // Navigator.of(context);
                              });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: ColorStyle.darkPurple,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              "Log out",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                              ),
                            )))
                    // Padding(
                    //   padding: EdgeInsets.only(left: 8, right: 16),
                    //   child: Icon(FeatherIcons.moreHorizontal),
                    // )
                  ],
                ),
              ),
              SizedBox(
                height: sizeH * 100 - 102,
                width: sizeW * 100,
                child: DefaultTabController(
                  length: 3,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          automaticallyImplyLeading: false,
                          expandedHeight: 184,
                          collapsedHeight: 184,
                          backgroundColor: Colors.white,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              height: 184,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 112,
                                    width: double.maxFinite,
                                    padding: EdgeInsets.only(
                                        left: 16, right: 16, bottom: 16),
                                    decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                          Color.fromRGBO(255, 255, 255, 0),
                                          Color.fromRGBO(0, 0, 0, 0.3)
                                        ])),
                                  ),
                                  Positioned(
                                    top: 152,
                                    left: 16,
                                    right: 16,
                                    child: SizedBox(
                                      width: double.maxFinite,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                              text: widget.user
                                                                  .followings
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          TextSpan(
                                                            text: ' Seguidos  ',
                                                          ),
                                                          TextSpan(
                                                              text: widget.user
                                                                  .followers
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          TextSpan(
                                                            text: ' Seguidores',
                                                          ),
                                                        ],
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 14,
                                                      ),
                                                    ),

                                                    // Text(
                                                    //   widget.user.email,
                                                    //   maxLines: 1,
                                                    //   overflow:
                                                    //       TextOverflow.ellipsis,
                                                    //   style: TextStyle(
                                                    //       fontWeight:
                                                    //           FontWeight.w400,
                                                    //       fontSize: 14,
                                                    //       color: Colors.black,
                                                    //       fontFamily: 'Montserrat'),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              PressTransform(
                                                onPressed: () {},
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 16),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(
                                                          color: ColorStyle
                                                              .borderGrey)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Editar Perfil",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                FeatherIcons.calendar,
                                                size: 18,
                                                color: ColorStyle.textGrey,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                widget.user
                                                    .getFormattedCreationDate(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: ColorStyle.textGrey,
                                                    fontFamily: 'Montserrat'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 56,
                                    left: 16,
                                    child: CircularAvatarW(
                                      externalRadius: Offset(88, 88),
                                      internalRadius: Offset(82, 82),
                                      nameAvatar:
                                          widget.user.name.substring(0, 1),
                                      isCompany: false,
                                      sizeText: 40,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                            pinned: true,
                            floating: true,
                            delegate: MyDelegate(
                              TabBar(
                                controller: _tabController,
                                labelColor: Colors.black,
                                isScrollable: true,
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.only(left: 24),
                                unselectedLabelColor: Colors.grey,
                                indicator: _customUnderlineIndicator(),
                                indicatorColor: ColorStyle.darkPurple,
                                indicatorWeight: 0,
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                                tabs: [
                                  Tab(text: 'Reseñas'),
                                  Tab(text: 'Comentarios'),
                                  Tab(text: 'Mis me gusta'),
                                ],
                              ),
                            )),
                      ];
                    },
                    body: BlocListener<FeedBloc, FeedState>(
                      listener: (BuildContext context, state) {
                        if (state is FeedLoaded) {
                          // Actualizar la lista de reseñas si alguna de ellas ha cambiado en el feed
                          _updateReviewsIfChanged(state.reviews);
                        }
                      },
                      child: RefreshIndicator.adaptive(
                        onRefresh: () async {
                          await loadReviews();
                          Future.delayed(Duration(milliseconds: 1000));
                        },
                        child: CustomScrollView(
                          physics: BouncingScrollPhysics(),
                          slivers: [
                            isLoading
                                ? const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 96),
                                      child: Center(
                                          child: CircularProgressIndicator
                                              .adaptive()),
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
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            )),
                                      )
                                    : SliverPadding(
                                        padding:
                                            const EdgeInsets.only(bottom: 128),
                                        sliver: SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            childCount: reviews
                                                .length, // número de items en la lista
                                            (BuildContext context, int index) {
                                              print(index);
                                              return ReviewCard(
                                                showBusiness: true,
                                                review: reviews[index],
                                                onFollowUser: () {},
                                                onFollowBusinnes: () {
                                                  _followBusiness(
                                                      reviews[index]);
                                                },
                                                onLike: () {
                                                  _likeReview(reviews[index]);
                                                },
                                                onDelete: () async {
                                                  try {
                                                    final response =
                                                        await ApiService()
                                                            .deleteReview(
                                                                reviews[index]
                                                                    .idReview);

                                                    if (response == 200) {
                                                      setState(() {
                                                        deleteReview(
                                                            reviews[index]
                                                                .idReview);
                                                      });
                                                      feedBloc.add(DeleteReview(
                                                          reviews[index]
                                                              .idReview));
                                                      if (mounted) {
                                                        showSuccessSnackBar(
                                                            context,
                                                            message:
                                                                "Se elimino la reseña exitosamente");
                                                      }
                                                    } else {
                                                      if (mounted) {
                                                        showErrorSnackBar(
                                                            context,
                                                            "No se pudo eliminar la reseña");
                                                      }
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      showErrorSnackBar(context,
                                                          "No se pudo eliminar la reseña");
                                                    }
                                                  }
                                                },
                                                onComment: () async {
                                                  final userBloc =
                                                      BlocProvider.of<UserBloc>(
                                                          context);
                                                  final userState =
                                                      userBloc.state;
                                                  if (userState is UserLoaded) {
                                                    Map<String,
                                                            dynamic>? response =
                                                        await showModalBottomSheet(
                                                            context: context,
                                                            isScrollControlled:
                                                                true,
                                                            useRootNavigator:
                                                                true,
                                                            barrierColor:
                                                                const Color
                                                                    .fromRGBO(0,
                                                                    0, 0, 0.1),
                                                            shape:
                                                                const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        20.0),
                                                              ),
                                                            ),
                                                            builder: (context) =>
                                                                BackdropFilter(
                                                                    filter: ImageFilter.blur(
                                                                        sigmaX:
                                                                            6,
                                                                        sigmaY:
                                                                            6),
                                                                    child:
                                                                        CommentBottomSheet(
                                                                      user: userState
                                                                          .user,
                                                                      name: reviews[
                                                                              index]
                                                                          .user
                                                                          .name,
                                                                      lastName: reviews[
                                                                              index]
                                                                          .user
                                                                          .lastName,
                                                                      content: reviews[
                                                                              index]
                                                                          .content,
                                                                    )));

                                                    if (response != null) {
                                                      try {
                                                        final commentResponse =
                                                            await ApiService().commentReview(
                                                                content: response[
                                                                    'content'],
                                                                idReview: reviews[
                                                                        index]
                                                                    .idReview);

                                                        addCommentToReview(
                                                          reviews[index]
                                                              .idReview,
                                                        );

                                                        feedBloc.add(AddComment(
                                                            comment:
                                                                commentResponse,
                                                            reviewId:
                                                                reviews[index]
                                                                    .idReview));
                                                        return 200;
                                                      } catch (e) {
                                                        if (mounted) {
                                                          showErrorSnackBar(
                                                              context,
                                                              'No se pudo agregar el comentario');
                                                        }
                                                      }
                                                    }
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  UnderlineTabIndicator _customUnderlineIndicator() {
    return UnderlineTabIndicator(
      borderSide: BorderSide(
          width: 3.0, color: Colors.purple), // Grosor y color del indicador
      borderRadius: BorderRadius.circular(2),
      insets: EdgeInsets.fromLTRB(8.0, 0.0, 8.0,
          0.0), // Ajusta el espacio a los lados y debajo del texto
    );
  }
}

class MyDelegate extends SliverPersistentHeaderDelegate {
  MyDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return Material(
        child: Container(height: 34, color: Colors.white, child: tabBar));
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 34;

  @override
  // TODO: implement minExtent
  double get minExtent => 34;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return false;
  }
}
