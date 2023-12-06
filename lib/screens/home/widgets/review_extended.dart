// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_feather_icons/flutter_feather_icons.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:w_app/bloc/user_bloc/user_bloc.dart';
// import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
// import 'package:w_app/models/comment_model.dart';
// import 'package:w_app/models/review_model.dart';
// import 'package:w_app/models/user.dart';
// import 'package:w_app/screens/actions/comments_screen.dart';
// import 'package:w_app/screens/home/widgets/comment_card.dart';
// import 'package:w_app/screens/home/widgets/review_card.dart';
// import 'package:w_app/services/api/api_service.dart';
// import 'package:w_app/styles/color_style.dart';
// import 'package:w_app/widgets/circularAvatar.dart';
// import 'package:w_app/widgets/press_transform_widget.dart';
// import 'package:w_app/widgets/snackbar.dart';

// class ReviewExtendedWidget extends StatefulWidget {
//   final Review review;

//   ReviewExtendedWidget({
//     required this.review,
//   });

//   @override
//   State<ReviewExtendedWidget> createState() => _ReviewExtendedWidgetState();
// }

// class _ReviewExtendedWidgetState extends State<ReviewExtendedWidget> {
//   late UserBloc _userBloc;
//   List<Comment> comments = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _userBloc = BlocProvider.of<UserBloc>(context);
//     _loadReviews();
//   }

//   Future<void> _loadReviews() async {
//     try {
//       var commentsList =
//           await ApiService().getReviewsParentComments(widget.review.idReview);
//       setState(() {
//         comments = commentsList;
//         isLoading = false;
//       });
//     } catch (e) {
//       // Handle the error or set state to show an error message
//       showErrorSnackBar(context, e.toString());
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _likeReview(Comment comment) async {
//     // Asigna el valor contrario de isLiked y ajusta los likes de forma local primero.
//     bool newIsLiked = !comment.isLiked;
//     int newLikes = comment.isLiked ? comment.likes - 1 : comment.likes + 1;

//     // Actualiza la UI inmediatamente para una respuesta rápida.
//     setState(() {
//       comments = comments
//           .map((r) => r.idComment == comment.idComment
//               ? r.copyWith(isLiked: newIsLiked, likes: newLikes)
//               : r)
//           .toList();
//     });

//     // Realiza la llamada al servicio.
//     final response =
//         await ApiService().likeComment(idComment: comment.idComment);
//     print(response);

//     // Si la respuesta no es exitosa, revierte el cambio en la UI.
//     if (response != 200 && response != 201) {
//       setState(() {
//         comments = comments
//             .map((r) => r.idComment == comment.idComment
//                 ? r.copyWith(isLiked: !newIsLiked, likes: r.likes)
//                 : r)
//             .toList();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sizeW = MediaQuery.of(context).size.width / 100;
//     final sizeH = MediaQuery.of(context).size.height / 100;
//     final stateUser = BlocProvider.of<UserBloc>(context).state;

//     return stateUser is UserLoaded
//         ? isLoading
//             ? const SliverToBoxAdapter(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 96),
//                   child: Center(child: CircularProgressIndicator.adaptive()),
//                 ),
//               )
//             : comments.isEmpty
//                 ? const SliverToBoxAdapter(
//                     child: Padding(
//                         padding: EdgeInsets.only(top: 96),
//                         child: Center(
//                           child: Text(
//                             'Parece que no hay data',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 fontFamily: "Montserrat",
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w400),
//                           ),
//                         )),
//                   )
//                 : SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                       childCount: comments.length,
//                       (BuildContext context, int index) {
//                         return GestureDetector(
//                           onTap: () {},
//                           child: CommentWidget(
//                             comment: comments[index],
//                             user: stateUser.user,
//                             onFollowUser: () {},
//                             onLike: () {
//                               _likeReview(comments[index]);
//                             },
//                             onComment: () async {
//                               final userState = _userBloc.state;
//                               print("saoa");
//                               if (userState is UserLoaded) {
//                                 print("hey");
//                                 Map<String, dynamic>? response =
//                                     await showModalBottomSheet(
//                                         context: context,
//                                         isScrollControlled: true,
//                                         useRootNavigator: true,
//                                         barrierColor:
//                                             const Color.fromRGBO(0, 0, 0, 0.1),
//                                         shape: const RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.only(
//                                             topLeft: Radius.circular(20.0),
//                                             topRight: Radius.circular(20.0),
//                                           ),
//                                         ),
//                                         builder: (context) =>
//                                             CommentBottomSheet(
//                                               user: userState.user,
//                                               name: comments[index].user.name,
//                                               lastName:
//                                                   comments[index].user.lastName,
//                                               content: comments[index].content,
//                                             ));

//                                 if (response != null) {
//                                   // _feedBloc.add(AddComment(
//                                   //     content: response['content'],
//                                   //    ));

//                                   ApiService().commentReview(
//                                       content: response['content'],
//                                       idReview: comments[index].idReview,
//                                       idParent: comments[index].idParent);
//                                 }
//                                 print(response);
//                               }
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   )
//         : const SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.only(top: 96),
//               child: Center(child: Text("error")),
//             ),
//           );
//   }
// }
