import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/actions/comments_screen.dart';
import 'package:w_app/screens/add/add_review.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/screens/home/widgets/comment_card.dart';
import 'package:w_app/screens/home/widgets/review_extended.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class ReviewPage extends StatefulWidget {
  final Review review;
  final VoidCallback onLike;
  final Future Function() onComment;
  final VoidCallback onFollowUser;
  final VoidCallback onFollowBusiness;
  final VoidCallback? onDelete;
  const ReviewPage(
      {super.key,
      required this.review,
      required this.onLike,
      required this.onComment,
      required this.onFollowUser,
      this.onDelete,
      required this.onFollowBusiness});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Review review;
  late UserBloc _userBloc;
  List<Comment> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    review = widget.review;
    _userBloc = BlocProvider.of<UserBloc>(context);
    _loadReviews();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    comments.clear();
    // _userBloc.close();

    super.dispose();
  }
  // late Future<List<Comment>> futureListReviewComment;

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;
    final stateUser = BlocProvider.of<UserBloc>(context).state;

    return Scaffold(
      body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: [
              Positioned.fill(
                top: 96,
                child: stateUser is UserLoaded
                    ? RefreshIndicator.adaptive(
                        color: ColorStyle.darkPurple,
                        onRefresh: () async {
                          await _loadReviews();
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                        },
                        child: CustomScrollView(
                          physics: BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: ReviewCard(
                                isThread: true,
                                isActive: false,
                                review: review,
                                onDelete: () async {
                                  widget.onDelete?.call();
                                  Navigator.of(context).pop();
                                },
                                onComment: () async {
                                  //falta arreglar esto
                                  await widget.onComment().then((value) async {
                                    if (value == 200) {
                                      print(value);
                                      addCommentToReview();
                                    }
                                  });
                                  await _loadReviews();

                                  setState(() {});
                                },
                                onLike: () {
                                  setState(() {
                                    review = review.copyWith(
                                        isLiked: !review.isLiked,
                                        likes: review.isLiked
                                            ? review.likes - 1
                                            : review.likes + 1);
                                  });
                                  widget.onLike();
                                },
                                onFollowBusinnes: () {
                                  _followBusiness(review.business!);
                                  widget.onFollowBusiness();
                                },
                                onFollowUser: () {
                                  _followUser(review.user);
                                  widget.onFollowUser();
                                },
                              ),
                            ),
                            // ReviewExtendedWidget(
                            //   review: review,
                            // ),

                            isLoading
                                ? const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 96),
                                      child: Center(
                                          child: CircularProgressIndicator
                                              .adaptive()),
                                    ),
                                  )
                                : comments.isEmpty
                                    ? const SliverToBoxAdapter(
                                        child: Padding(
                                            padding: EdgeInsets.only(top: 96),
                                            child: Center(
                                              child: Text(
                                                '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            )),
                                      )
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          childCount: comments.length,
                                          (BuildContext context, int index) {
                                            return CommentWidget(
                                              comment: comments[index],
                                              user: stateUser.user,
                                              onFollowUser: () {
                                                _followUser(
                                                    comments[index].user);
                                              },
                                              onLike: () {
                                                _likeComment(comments[index]);
                                              },
                                              onComment: () async {
                                                final userState =
                                                    _userBloc.state;

                                                if (userState is UserLoaded) {
                                                  Map<String, dynamic>?
                                                      response =
                                                      await showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          useRootNavigator:
                                                              true,
                                                          barrierColor:
                                                              const Color
                                                                  .fromRGBO(
                                                                  0, 0, 0, 0.1),
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
                                                              CommentBottomSheet(
                                                                user: userState
                                                                    .user,
                                                                name: comments[
                                                                        index]
                                                                    .user
                                                                    .name,
                                                                lastName: comments[
                                                                        index]
                                                                    .user
                                                                    .lastName,
                                                                content: comments[
                                                                        index]
                                                                    .content,
                                                              ));

                                                  if (response != null) {
                                                    // _feedBloc.add(AddComment(
                                                    //     content: response['content'],
                                                    //    ));

                                                    ApiService().commentReview(
                                                        content:
                                                            response['content'],
                                                        idReview:
                                                            comments[index]
                                                                .idReview,
                                                        idParent:
                                                            comments[index]
                                                                .idParent);
                                                  }

                                                  await _loadReviews();

                                                  setState(() {});
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                            const SliverPadding(
                              padding: EdgeInsets.only(top: 200),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
              ),
              Positioned(
                bottom: 88,
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
                                  business: Business(
                                      idBusiness:
                                          widget.review.business!.idBusiness,
                                      name: widget.review.business!.name,
                                      entity:
                                          widget.review.business?.entity ?? '',
                                      address: '',
                                      state: '',
                                      city: '',
                                      country: '',
                                      isValid: true,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      averageRating:
                                          widget.review.business!.rating,
                                      followers: 2,
                                      isFollowed:
                                          widget.review.business!.followed),
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
                              'Agregar una reseña a ${widget.review.business?.name ?? ''}',
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
                ),
              ),
              Container(
                width: double.maxFinite,
                height: 96,
                padding: EdgeInsets.only(top: 32),
                decoration: BoxDecoration(color: Colors.white),
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
                      "Hilo",
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
              )
            ],
          )),
    );
  }

  Future<void> _loadReviews() async {
    try {
      var commentsList =
          await ApiService().getReviewsParentComments(widget.review.idReview);
      setState(() {
        comments = commentsList;
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

  void _followBusiness(BusinessData business) {
    setState(() {
      // Actualizar el estado de 'followed' del usuario en la reseña si corresponde
      if (review.business!.idBusiness == business.idBusiness) {
        review = review.copyWith(
            business: review.business!
                .copyWith(followed: !review.business!.followed));
      }
    });
  }

  void _followUser(UserData user) {
    setState(() {
      // Actualizar el estado de 'followed' del usuario en la reseña si corresponde
      if (review.user.idUser == user.idUser) {
        review = review.copyWith(
            user: review.user.copyWith(followed: !review.user.followed));
      }

      // Actualizar el estado de 'followed' del usuario en los comentarios
      comments = comments.map((comment) {
        if (comment.user.idUser == user.idUser) {
          return comment.copyWith(
              user: comment.user.copyWith(followed: !comment.user.followed));
        }
        return comment;
      }).toList();
    });

    // Llamar a la función de callback para seguir al usuario
    widget.onFollowUser();
  }

  void _likeComment(Comment comment) async {
    // Asigna el valor contrario de isLiked y ajusta los likes de forma local primero.
    bool newIsLiked = !comment.isLiked;
    int newLikes = comment.isLiked ? comment.likes - 1 : comment.likes + 1;

    // Actualiza la UI inmediatamente para una respuesta rápida.
    setState(() {
      comments = comments
          .map((r) => r.idComment == comment.idComment
              ? r.copyWith(isLiked: newIsLiked, likes: newLikes)
              : r)
          .toList();
    });

    // Realiza la llamada al servicio.
    final response =
        await ApiService().likeComment(idComment: comment.idComment);

    // Si la respuesta no es exitosa, revierte el cambio en la UI.
    if (response != 200 && response != 201) {
      setState(() {
        comments = comments
            .map((r) => r.idComment == comment.idComment
                ? r.copyWith(isLiked: !newIsLiked, likes: r.likes)
                : r)
            .toList();
      });
    }
  }

  void addCommentToReview() {
    setState(() {
      review = review.copyWith(comments: review.comments + 1);
    });
  }
}
