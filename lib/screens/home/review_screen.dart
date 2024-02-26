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
import 'package:w_app/screens/actions/comment_bottom_sheet.dart';
import 'package:w_app/screens/add/add_review.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/screens/home/widgets/comment_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/arrow_back_widget.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class ReviewPage extends StatefulWidget {
  final Review review;
  final VoidCallback onLike;
  final Future Function() onComment;
  final VoidCallback onFollowUser;
  final VoidCallback onFollowBusiness;
  final VoidCallback? onDelete;
  final bool? isUniqueRoute;
  const ReviewPage(
      {super.key,
      required this.review,
      required this.onLike,
      required this.onComment,
      required this.onFollowUser,
      this.onDelete,
      required this.onFollowBusiness,
      this.isUniqueRoute});

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
    super.initState();
    review = widget.review;
    _userBloc = BlocProvider.of<UserBloc>(context);
    _loadComments();
  }

  @override
  void dispose() {
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
      body: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: [
              Positioned.fill(
                top: 96,
                child: stateUser is UserLoaded
                    ? RefreshIndicator.adaptive(
                        color: ColorStyle.darkPurple,
                        backgroundColor: ColorStyle.grey,
                        onRefresh: () async {
                          await _loadComments();
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                        },
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
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
                                      addCommentToReview();
                                    }
                                  });
                                  await _loadComments();

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
                                              userMain: stateUser.user,
                                              onFollowUser: () {
                                                _followUser(
                                                    comments[index].user);
                                              },
                                              onLike: () {
                                                _likeComment(comments[index]);
                                              },
                                              onDelete: () async {
                                                try {
                                                  final response =
                                                      await ApiService()
                                                          .deleteComment(
                                                              comments[index]
                                                                  .idComment);
                                                  if (response == 200) {
                                                    setState(() {
                                                      comments.removeAt(index);
                                                      review = review.copyWith(
                                                          comments:
                                                              review.comments -
                                                                  1);
                                                    });
                                                    if (mounted) {
                                                      showSuccessSnackBar(
                                                          context,
                                                          message:
                                                              "Se elimino el comentario exitosamente");
                                                    }
                                                    return true;
                                                  } else {
                                                    if (mounted) {
                                                      showErrorSnackBar(context,
                                                          "No se pudo eliminar el comentario");
                                                    }
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    showErrorSnackBar(context,
                                                        "No se pudo eliminar el comentario");
                                                  }
                                                }
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
                                                                images: comments[
                                                                        index]
                                                                    .images,
                                                              ));

                                                  if (response != null) {
                                                    try {
                                                      await ApiService()
                                                          .commentReview(
                                                              content: response[
                                                                  'content'],
                                                              idReview:
                                                                  comments[
                                                                          index]
                                                                      .idReview,
                                                              idParent: comments[
                                                                      index]
                                                                  .idComment);
                                                      if (mounted) {
                                                        showSuccessSnackBar(
                                                            context);
                                                      }

                                                      addCommentToComment(
                                                          index);
                                                      await _loadComments();
                                                    } catch (e) {
                                                      if (mounted) {
                                                        showErrorSnackBar(
                                                            context,
                                                            e.toString());
                                                      }
                                                    }
                                                  }
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
                    : const SizedBox(),
              ),
              Positioned(
                bottom: widget.isUniqueRoute ?? false ? 0 : 80,
                child: Container(
                  width: sizeW * 100,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border.symmetric(
                          horizontal: BorderSide(
                              color: ColorStyle.borderGrey, width: 0.5))),
                  padding: const EdgeInsets.only(
                      bottom: 16, top: 16, left: 16, right: 16),
                  child: PressTransform(
                    onPressed: () async {
                      await widget.onComment().then((value) async {
                        if (value == 200) {
                          addCommentToReview();
                        }
                      });
                      await _loadComments();

                      setState(() {});
                    },
                    child: Container(
                      width: double.maxFinite,
                      height: 40,
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: ColorStyle.lightGrey),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Responder a ${widget.review.user.name} ${widget.review.user.lastName}',
                              maxLines: 1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          SvgPicture.asset(
                            'assets/images/icons/commentReview.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
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
                padding: const EdgeInsets.only(top: 32),
                decoration: const BoxDecoration(color: Colors.white),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: PressTransform(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: ArrowBackWidget(),
                      ),
                    ),
                    const Text(
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

  Future<void> _loadComments() async {
    try {
      var commentsList =
          await ApiService().getReviewsParentComments(widget.review.idReview);

      print(widget.review.idReview);
      setState(() {
        comments = commentsList;
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

  void addCommentToComment(int index) {
    setState(() {
      comments = comments.map((itemComment) {
        return itemComment.idComment == comments[index].idComment
            ? comments[index].copyWith(comments: comments[index].comments + 1)
            : itemComment;
      }).toList();
    });
  }
}
