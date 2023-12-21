import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/actions/comments_screen.dart';
import 'package:w_app/screens/home/widgets/comment_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/widgets/snackbar.dart';

class CommentPage extends StatefulWidget {
  final Comment comment;
  final VoidCallback onLike;
  final Future Function() onComment;
  final VoidCallback onFollowUser;
  final User user;
  const CommentPage(
      {super.key,
      required this.comment,
      required this.user,
      required this.onLike,
      required this.onComment,
      required this.onFollowUser});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  // late Future<List<Comment>> futureListReviewComment;
  late UserBloc _userBloc;
  late Comment comment;
  List<Comment> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userBloc = BlocProvider.of<UserBloc>(context);
    comment = widget.comment;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      var commentsList =
          await ApiService().getCommentChildren(widget.comment.idComment);
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

  void addCommentToComment() {
    setState(() {
      comment = comment.copyWith(comments: comment.comments + 1);
    });
  }

  void _followUser(UserData user) {
    setState(() {
      // Actualizar el estado de 'followed' del usuario en la reseña si corresponde
      if (comment.user.idUser == user.idUser) {
        comment = comment.copyWith(
            user: comment.user.copyWith(followed: !comment.user.followed));
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
  }

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
                              child: CommentWidget(
                                  isThread: true,
                                  isActive: false,
                                  comment: comment,
                                  user: widget.user,
                                  onComment: () async {
                                    await widget.onComment();
                                    await _loadReviews();
                                    addCommentToComment();
                                  },
                                  onFollowUser: () {
                                    _followUser(comment.user);
                                    widget.onFollowUser();
                                  },
                                  onLike: () {
                                    setState(() {
                                      comment = comment.copyWith(
                                          isLiked: !comment.isLiked,
                                          likes: comment.isLiked
                                              ? comment.likes - 1
                                              : comment.likes + 1);
                                    });
                                    widget.onLike();
                                  })),

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
                                        childCount: comments.length,
                                        (BuildContext context, int index) {
                                          return CommentWidget(
                                            comment: comments[index],
                                            user: stateUser.user,
                                            onFollowUser: () {},
                                            onLike: () {
                                              _likeComment(comments[index]);
                                            },
                                            onComment: () async {
                                              final userState = _userBloc.state;
                                              print("saoa");
                                              if (userState is UserLoaded) {
                                                print("hey");
                                                Map<String, dynamic>? response =
                                                    await showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        useRootNavigator: true,
                                                        barrierColor:
                                                            const Color
                                                                .fromRGBO(
                                                                0, 0, 0, 0.1),
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    20.0),
                                                            topRight:
                                                                Radius.circular(
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
                                                              lastName:
                                                                  comments[
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
                                                      idReview: comments[index]
                                                          .idReview,
                                                      idParent: comments[index]
                                                          .idComment);
                                                }
                                                print(response);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),

                          SliverPadding(
                            padding: EdgeInsets.only(top: 112),
                          ),
                          // for (Comment comment in []) CommentWidget(comment: comment),
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
}
