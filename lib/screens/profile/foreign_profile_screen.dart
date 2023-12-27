import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/actions/comment_bottom_sheet.dart';
import 'package:w_app/screens/chat/chat_screen.dart';
import 'package:w_app/screens/chat/inbox_screen.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class ForeignProfileScreen extends StatefulWidget {
  final User user;

  const ForeignProfileScreen(this.user, {super.key});

  @override
  State<ForeignProfileScreen> createState() => _ForeignProfileScreenState();
}

class _ForeignProfileScreenState extends State<ForeignProfileScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Review>> futureListReview;
  List<Review> reviews = [];
  bool isLoading = true;
  late FeedBloc feedBloc;
  late UserBloc userBloc;
  late User userMain;
  late User currentUser;
  TabController? _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = widget.user; // Inicializa con el usuario del widget
    _tabController = TabController(length: 3, vsync: this);
    feedBloc = BlocProvider.of<FeedBloc>(context);
    userBloc = BlocProvider.of<UserBloc>(context);
    final stateUser = userBloc.state;
    if (stateUser is UserLoaded) {
      userMain = stateUser.user;
    }

    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      var reviewsList = await ApiService().getUserReviews(currentUser.idUser);
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
    // Call the API to update the 'like' status
    feedBloc.add(LikeReview(review));
  }

  void _followUser() {
    // Update the review with the new 'like' status
    setState(() {
      currentUser = currentUser.copyWith(
          isFollowed: !currentUser.isFollowed!,
          followers: currentUser.isFollowed!
              ? currentUser.followers - 1
              : currentUser.followers + 1);
      // Actualizar el estado de 'followed' del usuario en los comentarios
      reviews = reviews.map((reviewItem) {
        return reviewItem.copyWith(
            user:
                reviewItem.user.copyWith(followed: !reviewItem.user.followed));
      }).toList();
    });

    // Call the API to update the 'like' status
    feedBloc.add(FollowUser(currentUser.idUser));
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
    // Call the API to update the 'like' status
    feedBloc.add(FollowBusiness(review.business?.idBusiness ?? ''));
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
      appBar: null,
      body: Column(
        children: [
          Container(
            width: sizeW * 100,
            height: 102,
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            color: Colors.white,
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 0, right: 8),
                    child: Icon(FeatherIcons.arrowLeft),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${currentUser.name} ${currentUser.lastName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Montserrat'),
                  ),
                ),

                Visibility(
                  visible: !(userMain.idUser == currentUser.idUser),
                  child: PressTransform(
                    onPressed: () async {
                      String? tk = await UserRepository().getToken();
                      if (tk != null) {
                        if (userMain.idUser != currentUser.idUser) {
                          //Sacar el token largo, el; corto ya esta
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                    settings: const RouteSettings(),
                                    builder: (context) => InboxScreen(
                                        receiver: currentUser.idUser,
                                        receiverName: currentUser.name +
                                            " " +
                                            currentUser.lastName,
                                        initials: userMain.name[0] +
                                            userMain.lastName[0])));
                          }
                        } else {
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true)
                                .push(MaterialPageRoute(
                                    settings: const RouteSettings(),
                                    builder: (context) => ChatPage(
                                          user: userMain,
                                        )));
                          }
                        }
                      } else {
                        print("Token no provisto o no valido");
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorStyle.borderGrey)),
                      child: const Icon(
                        FeatherIcons.mail,
                        size: 20,
                      ),
                    ),
                  ),
                )

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
                        background: SizedBox(
                          height: 184,
                          child: Stack(
                            children: [
                              Container(
                                height: 112,
                                width: double.maxFinite,
                                padding: const EdgeInsets.only(
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
                                                          text: currentUser
                                                              .followings
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      const TextSpan(
                                                        text: ' Seguidos   ',
                                                      ),
                                                      TextSpan(
                                                          text: currentUser
                                                              .followers
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      const TextSpan(
                                                        text: ' Seguidores',
                                                      ),
                                                    ],
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                // Text(
                                                //   currentUser.email,
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
                                          Visibility(
                                            visible: !(userMain.idUser ==
                                                currentUser.idUser),
                                            child: PressTransform(
                                              onPressed: () {
                                                _followUser();

                                                setState(() {});
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 16),
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                      currentUser.isFollowed!
                                                          ? "Siguiendo"
                                                          : "Seguir",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: currentUser
                                                                      .isFollowed ??
                                                                  false
                                                              ? ColorStyle
                                                                  .solidBlue
                                                              : Colors.black,
                                                          fontFamily:
                                                              'Montserrat'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            FeatherIcons.calendar,
                                            size: 18,
                                            color: ColorStyle.textGrey,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            currentUser
                                                .getFormattedCreationDate(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
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
                                  externalRadius: const Offset(88, 88),
                                  internalRadius: const Offset(82, 82),
                                  nameAvatar: currentUser.name.substring(0, 1),
                                  isCompany: false,
                                  sizeText: 40,
                                  urlImage: currentUser.profilePictureUrl,
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
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(left: 24),
                            unselectedLabelColor: Colors.grey,
                            indicator: _customUnderlineIndicator(),
                            indicatorColor: ColorStyle.darkPurple,
                            indicatorWeight: 0,
                            labelStyle: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                            tabs: const [
                              Tab(text: 'Reseñas'),
                              Tab(text: 'Comentarios'),
                              Tab(text: 'Me gusta'),
                            ],
                          ),
                        )),
                  ];
                },
                body: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
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
                                      onFollowUser: () async {
                                        _followUser();
                                      },
                                      onFollowBusinnes: () {
                                        _followBusiness(reviews[index]);
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
                                                            images:
                                                                reviews[index]
                                                                    .images,
                                                          )));
                                          if (response != null) {
                                            try {
                                              final responseComment =
                                                  await ApiService()
                                                      .commentReview(
                                                          content: response[
                                                              'content'],
                                                          idReview:
                                                              reviews[index]
                                                                  .idReview);

                                              addCommentToReview(
                                                  reviews[index].idReview);

                                              if (mounted) {
                                                showSuccessSnackBar(context);
                                              }

                                              try {
                                                if (response['images'] !=
                                                    null) {
                                                  final imagesResponse =
                                                      await ApiService()
                                                          .uploadCommentImages(
                                                    responseComment.idComment,
                                                    response['images'],
                                                  );

                                                  if (imagesResponse
                                                              .statusCode ==
                                                          201 ||
                                                      imagesResponse
                                                              .statusCode ==
                                                          200) {
                                                    final jsonImageResponse =
                                                        json.decode(
                                                            imagesResponse
                                                                .body);

                                                    print(jsonImageResponse);

                                                    // Convierte cada elemento de la lista a una cadena (String)
                                                    List<String> dynamicList =
                                                        List<String>.from(
                                                            jsonImageResponse[
                                                                    'Images']
                                                                .map((e) => e
                                                                    .toString()));

                                                    // newReview = newReview.copyWith(
                                                    //     images: stringList);
                                                  }
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  showErrorSnackBar(context,
                                                      "No se logró subir imagenes");
                                                }
                                              }

                                              // _feedBloc.add(AddComment(
                                              //     comment:
                                              //         responseComment,
                                              //     reviewId: state
                                              //         .reviews[
                                              //             index]
                                              //         .idReview));

                                              return 200;
                                            } catch (e) {
                                              if (mounted) {
                                                print("a--a");
                                                print(e);
                                                showErrorSnackBar(context,
                                                    'No se pudo agregar el comentario');
                                              }
                                            }
                                          }
                                        }
                                      },
                                    );
                                  },
                                  childCount: reviews
                                      .length, // número de items en la lista
                                ),
                              )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  UnderlineTabIndicator _customUnderlineIndicator() {
    return UnderlineTabIndicator(
      borderSide: const BorderSide(
          width: 3.0, color: Colors.purple), // Grosor y color del indicador
      borderRadius: BorderRadius.circular(2),
      insets: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0,
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
