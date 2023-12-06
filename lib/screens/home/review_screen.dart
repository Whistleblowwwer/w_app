import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/actions/comments_screen.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/screens/home/widgets/comment_card.dart';
import 'package:w_app/screens/home/widgets/review_extended.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/widgets/snackbar.dart';

class ReviewPage extends StatefulWidget {
  final Review review;
  final VoidCallback onLike;
  final Future Function() onComment;
  final VoidCallback onFollowUser;
  final VoidCallback onFollowBusiness;
  const ReviewPage(
      {super.key,
      required this.review,
      required this.onLike,
      required this.onComment,
      required this.onFollowUser,
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
    _userBloc.close();

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
              stateUser is UserLoaded
                  ? Container(
                      width: sizeW * 100,
                      height: sizeH * 100,
                      child: CustomScrollView(
                        physics: BouncingScrollPhysics(),
                        slivers: [
                          const SliverPadding(
                            padding: EdgeInsets.only(top: 96),
                          ),
                          SliverToBoxAdapter(
                            child: ReviewCard(
                              isThread: true,
                              isActive: false,
                              review: review,
                              onComment: () async {
                                //falta arreglar esto
                                await widget.onComment().then((value) async {
                                  await _loadReviews();
                                });

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
                          stateUser is UserLoaded
                              ? isLoading
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
                                                  print("saoa");
                                                  if (userState is UserLoaded) {
                                                    print("hey");
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
                                                                CommentBottomSheet(
                                                                  user:
                                                                      userState
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
                                                          content: response[
                                                              'content'],
                                                          idReview:
                                                              comments[index]
                                                                  .idReview,
                                                          idParent:
                                                              comments[index]
                                                                  .idParent);
                                                    }

                                                    await _loadReviews();
                                                    print(response);
                                                    setState(() {});
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        )
                              : const SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 96),
                                    child: Center(child: Text("error")),
                                  ),
                                ),
                          SliverPadding(
                            padding: EdgeInsets.only(top: 112),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              Container(
                width: double.maxFinite,
                height: 96,
                padding: EdgeInsets.only(top: 32),
                decoration: BoxDecoration(color: Colors.white),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 8),
                        child: Icon(FeatherIcons.arrowLeft),
                      ),
                      Text(
                        "Hilo",
                        style: TextStyle(fontFamily: 'Montserrat'),
                      )
                    ],
                  ),
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
    print(response);

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
}
