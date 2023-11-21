import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/feed_bloc/feed_state.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/actions/comments_screen.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';

class HomeScreen extends StatefulWidget {
  final UserRepository userRepository;

  const HomeScreen(this.userRepository);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserBloc _userBloc;
  late FeedBloc _feedBloc;
  late Future<List<Review>> futureReview;

  @override
  void initState() {
    super.initState();
    futureReview = ApiService().getReviews();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _feedBloc = BlocProvider.of<FeedBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _feedBloc.add(FetchFeedReviews());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16, bottom: 0),
                  padding: EdgeInsets.only(bottom: 16),
                  height: Platform.isIOS ? 96 : 88,
                  width: double.maxFinite,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logos/imagew.png',
                        width: 40,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                                color: ColorStyle.lightGrey,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              "Banca",
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            margin: EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                                color: ColorStyle.lightGrey,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              "Asesores",
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ),
                          Icon(FeatherIcons.messageSquare),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: BlocBuilder<FeedBloc, FeedState>(
                      builder: (context, state) {
                        if (state is FeedLoaded) {
                          return SingleChildScrollView(
                            padding: EdgeInsets.only(top: 0, bottom: 256),
                            child: Column(
                              children: List.generate(
                                state.reviews.length,
                                (index) => ReviewCard(
                                  review: state.reviews[index],
                                  onFollowUser: () {
                                    _feedBloc
                                        .add(FollowUser(state.reviews[index]));
                                  },
                                  onLike: () {
                                    _feedBloc
                                        .add(LikeReview(state.reviews[index]));
                                  },
                                  onComment: () async {
                                    final userState = _userBloc.state;
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
                                                        review: state
                                                            .reviews[index],
                                                      )));

                                      if (response != null) {
                                        _feedBloc.add(AddComment(
                                            content: response['content'],
                                            reviewId: response['idReview']));
                                      }
                                      print(response);
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        } else if (state is FeedLoading) {
                          return Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: Center(
                                child: CircularProgressIndicator.adaptive()),
                          );
                        } else if (state is FeedError) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 256,
                              ),
                              const Text(
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
                                'Parece que hubo un error\n${state.error.toString()}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 104,
              child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      futureReview = ApiService().getReviews();
                    });
                    // Aquí va el código que quieres ejecutar cuando se presiona el botón
                  },
                  child: Icon(
                    Icons.refresh,
                    size: 26,
                    color: Colors.white,
                  ),
                  backgroundColor: ColorStyle.darkPurple),
            )
          ],
        ),
      ),
    );
  }
}
