import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:uni_links/uni_links.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/socket_bloc/socket_bloc.dart';
import 'package:w_app/bloc/socket_bloc/socket_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/actions/comment_bottom_sheet.dart';
import 'package:w_app/screens/add/add_review.dart';
import 'package:w_app/screens/alert/alert_screen.dart';
import 'package:w_app/screens/chat/inbox_screen.dart';
import 'package:w_app/screens/home/comment_screen.dart';
import 'package:w_app/screens/home/home_screen.dart';
import 'package:w_app/screens/home/review_screen.dart';
import 'package:w_app/screens/profile/foreign_profile_screen.dart';
import 'package:w_app/screens/profile/profile_screen.dart';
import 'package:w_app/screens/search/search_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class StartPage extends StatefulWidget {
  final UserRepository userRepository;
  const StartPage({Key? key, required this.userRepository}) : super(key: key);

  @override
  StartPageState createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  var currentIndex = 0;

  late AuthBloc _authBloc;
  late UserBloc _userBloc;
  late SocketBloc _socketBloc;
  late FeedBloc _feedBloc;

  String? userId;

  final Map<int, GlobalKey<NavigatorState>> navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
    4: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Es seguro usar el context aquí
        _authBloc = BlocProvider.of<AuthBloc>(context);
        _userBloc = BlocProvider.of<UserBloc>(context);
        _feedBloc = BlocProvider.of<FeedBloc>(context);
        _fetchUserProfile();
        _socketBloc = BlocProvider.of<SocketBloc>(context);
        _socketBloc.add(Connect());
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print(message.data);
      print(message.notification?.title);
      print(message.notification?.body);

      try {
        await handleNotificationClick(context, message);
      } catch (e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: false).push(MaterialPageRoute(
            builder: (context) => AlertScreen(widget.userRepository),
          ));
        }
      }
    });
  }

  Future<void> _fetchUserProfile() async {
    final token = await widget.userRepository.getToken();
    if (token != null) {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print(decodedToken);

      final String userId =
          decodedToken['_id_user']; // Asume que el ID está bajo la clave 'id'
      print(userId);
      _userBloc.add(FetchUserProfile());
    }
  }

  Future<void> handleNotificationClick(
      BuildContext context, RemoteMessage message) async {
    print(message.data);
    switch (message.data['target_type']) {
      case "profile":
        final user =
            await ApiService().getProfileDetail(message.data['_id_target']);
        if (mounted) {
          Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(builder: (context) => ForeignProfileScreen(user)),
          );
        }
        break;
      case "review":
        final review = await ApiService().getReview(message.data['_id_target']);

        if (mounted) {
          Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(
                builder: (context) => ReviewPage(
                      review: review,
                      onLike: () {
                        _feedBloc.add(LikeReview(review));
                      },
                      onFollowUser: () {
                        _feedBloc.add(FollowUser(review.user.idUser));
                      },
                      onFollowBusiness: () {
                        _feedBloc
                            .add(FollowBusiness(review.business!.idBusiness));
                      },
                      onDelete: () async {
                        try {
                          final response =
                              await ApiService().deleteReview(review.idReview);

                          if (response == 200) {
                            setState(() {});
                            _feedBloc.add(DeleteReview(review.idReview));
                            if (mounted) {
                              showSuccessSnackBar(context,
                                  message: "Se elimino la reseña exitosamente");
                            }
                          } else {
                            if (mounted) {
                              showErrorSnackBar(
                                  context, "No se pudo eliminar la reseña");
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            showErrorSnackBar(
                                context, "No se pudo eliminar la reseña");
                          }
                        }
                      },
                      onComment: () async {
                        final userBloc = BlocProvider.of<UserBloc>(context);
                        final userState = userBloc.state;
                        if (userState is UserLoaded) {
                          Map<String, dynamic>? response =
                              await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useRootNavigator: true,
                                  barrierColor:
                                      const Color.fromRGBO(0, 0, 0, 0.1),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  builder: (context) => BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 6, sigmaY: 6),
                                      child: CommentBottomSheet(
                                        user: userState.user,
                                        name: review.user.name,
                                        lastName: review.user.lastName,
                                        content: review.content,
                                        images: review.images,
                                      )));

                          if (response != null) {
                            try {
                              final responseComment = await ApiService()
                                  .commentReview(
                                      content: response['content'],
                                      idReview: review.idReview);

                              if (mounted) {
                                showSuccessSnackBar(context);
                              }

                              try {
                                if (response['images'] != null) {
                                  final imagesResponse =
                                      await ApiService().uploadCommentImages(
                                    responseComment.idComment,
                                    response['images'],
                                  );

                                  if (imagesResponse.statusCode == 201 ||
                                      imagesResponse.statusCode == 200) {
                                    final jsonImageResponse =
                                        json.decode(imagesResponse.body);

                                    // Convierte cada elemento de la lista a una cadena (String)
                                    List<String> dynamicList =
                                        List<String>.from(
                                            jsonImageResponse['Images']
                                                .map((e) => e.toString()));

                                    // newReview = newReview.copyWith(
                                    //     images: stringList);
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  showErrorSnackBar(
                                      context, "No se logró subir imagenes");
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
                                showErrorSnackBar(context,
                                    'No se pudo agregar el comentario');
                              }
                            }
                          }
                        }
                      },
                    )),
          );
        }
        break;
      case "comment":
        final userBlocState = BlocProvider.of<UserBloc>(context).state;
        if (userBlocState is UserLoaded) {
          final comment =
              await ApiService().getComment(message.data['_id_target']);
          if (mounted) {
            Navigator.of(context, rootNavigator: false).push(
              MaterialPageRoute(
                  builder: (context) => CommentPage(
                        user: userBlocState.user,
                        comment: comment,
                        onLike: () async {
                          await ApiService()
                              .likeComment(idComment: comment.idComment);
                        },
                        onFollowUser: () {
                          _feedBloc.add(FollowUser(comment.user.idUser));
                        },
                        onDelete: () async {
                          try {
                            final response = await ApiService()
                                .deleteComment(comment.idComment);
                            if (response == 200) {
                              if (mounted) {
                                showSuccessSnackBar(context,
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
                              showErrorSnackBar(
                                  context, "No se pudo eliminar el comentario");
                            }
                          }
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
                                        const Color.fromRGBO(0, 0, 0, 0.1),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    builder: (context) => CommentBottomSheet(
                                          user: userState.user,
                                          name: comment.user.name,
                                          lastName: comment.user.lastName,
                                          content: comment.content,
                                          images: comment.images,
                                        ));

                            if (response != null) {
                              try {
                                await ApiService().commentReview(
                                    content: response['content'],
                                    idReview: comment.idReview,
                                    idParent: comment.idComment);
                                if (mounted) {
                                  showSuccessSnackBar(context);
                                }
                              } catch (e) {
                                if (mounted) {
                                  showErrorSnackBar(context, e.toString());
                                }
                              }
                            }
                          }
                        },
                      )),
            );
          }
        }
        break;
      case "chat":
        final userBlocState = BlocProvider.of<UserBloc>(context).state;
        if (userBlocState is UserLoaded) {
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              settings: const RouteSettings(),
              builder: (context) => InboxScreen(
                    receiver: message.data['_id_target'],
                    receiverName: message.notification?.title ?? 'Username',
                  )));
        }
        break;
      case "business":
        final review = await ApiService().getReview(message.data['_id_target']);

        if (mounted) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
                builder: (context) => ReviewPage(
                      review: review,
                      onLike: () {
                        _feedBloc.add(LikeReview(review));
                      },
                      onFollowUser: () {
                        _feedBloc.add(FollowUser(review.user.idUser));
                      },
                      onFollowBusiness: () {
                        _feedBloc
                            .add(FollowBusiness(review.business!.idBusiness));
                      },
                      onDelete: () async {
                        try {
                          final response =
                              await ApiService().deleteReview(review.idReview);

                          if (response == 200) {
                            setState(() {});
                            _feedBloc.add(DeleteReview(review.idReview));
                            if (mounted) {
                              showSuccessSnackBar(context,
                                  message: "Se elimino la reseña exitosamente");
                            }
                          } else {
                            if (mounted) {
                              showErrorSnackBar(
                                  context, "No se pudo eliminar la reseña");
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            showErrorSnackBar(
                                context, "No se pudo eliminar la reseña");
                          }
                        }
                      },
                      onComment: () async {
                        final userBloc = BlocProvider.of<UserBloc>(context);
                        final userState = userBloc.state;
                        if (userState is UserLoaded) {
                          Map<String, dynamic>? response =
                              await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useRootNavigator: true,
                                  barrierColor:
                                      const Color.fromRGBO(0, 0, 0, 0.1),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  builder: (context) => BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 6, sigmaY: 6),
                                      child: CommentBottomSheet(
                                        user: userState.user,
                                        name: review.user.name,
                                        lastName: review.user.lastName,
                                        content: review.content,
                                        images: review.images,
                                      )));

                          if (response != null) {
                            try {
                              final responseComment = await ApiService()
                                  .commentReview(
                                      content: response['content'],
                                      idReview: review.idReview);

                              if (mounted) {
                                showSuccessSnackBar(context);
                              }

                              try {
                                if (response['images'] != null) {
                                  final imagesResponse =
                                      await ApiService().uploadCommentImages(
                                    responseComment.idComment,
                                    response['images'],
                                  );

                                  if (imagesResponse.statusCode == 201 ||
                                      imagesResponse.statusCode == 200) {
                                    final jsonImageResponse =
                                        json.decode(imagesResponse.body);

                                    // Convierte cada elemento de la lista a una cadena (String)
                                    List<String> dynamicList =
                                        List<String>.from(
                                            jsonImageResponse['Images']
                                                .map((e) => e.toString()));

                                    // newReview = newReview.copyWith(
                                    //     images: stringList);
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  showErrorSnackBar(
                                      context, "No se logró subir imagenes");
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
                                showErrorSnackBar(context,
                                    'No se pudo agregar el comentario');
                              }
                            }
                          }
                        }
                      },
                    )),
          );
        }
        break;
      default:
        Navigator.of(context, rootNavigator: false).push(MaterialPageRoute(
          builder: (context) => AlertScreen(widget.userRepository),
        ));

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // double displayWidth = MediaQuery.of(context).size.width / 100;
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserTokenError) {
          _authBloc.add(LogOutUser());
        } else if (state is UserLoaded) {
          // showSuccessSnackBar(context);
        } else if (state is UserLoaded) {
          final message = state.message;
          if (message != '') {
            showErrorSnackBar(context, message);
          }
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color.fromRGBO(226, 226, 226, 1),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(
                  child: CircularProgressIndicator.adaptive(
                backgroundColor: ColorStyle.grey, // Fondo del indicador
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorStyle.darkPurple),
              ));
            } else if (state is UserLoaded) {
              return IndexedStack(
                index: currentIndex,
                children: [
                  Navigator(
                    key: navigatorKeys[0],
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) => HomeScreen(widget.userRepository),
                      );
                    },
                  ),
                  Navigator(
                    key: navigatorKeys[1],
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) =>
                            SearchScreen(widget.userRepository),
                      );
                    },
                  ),
                  Navigator(
                    key: navigatorKeys[2],
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) => HomeScreen(widget.userRepository),
                      );
                    },
                  ),
                  Navigator(
                    key: navigatorKeys[3],
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) =>
                            AlertScreen(widget.userRepository),
                      );
                    },
                  ),
                  Navigator(
                    key: navigatorKeys[4],
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) => ProfileScreen(state.user),
                      );
                    },
                  ),
                ],
              );
            } else if (state is UserError) {
              return Center(child: Text('Error: ${state.error}'));
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    double displayWidth = MediaQuery.of(context).size.width / 100;
    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 4, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, .08),
            blurRadius: 7,
            offset: Offset(0, -7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // This ensures that the icons are evenly spaced.
        children: listOfIconsActive
            .asMap()
            .map((key, value) => MapEntry(
                key,
                PressTransform(
                  onPressed: () async {
                    HapticFeedback.lightImpact();

                    if (currentIndex == key) {
                      navigatorKeys[key]
                          ?.currentState
                          ?.popUntil((route) => route.isFirst);
                    } else {
                      if (key == 2) {
                        final userState = _userBloc.state;
                        if (userState is UserLoaded) {
                          showModalBottomSheet(
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
                                  filter:
                                      ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                  child: CombinedBottomSheet(
                                    user: userState.user,
                                  )));
                        }
                      } else {
                        if (key == 4) {
                          _userBloc.add(LoadUserProfile());
                        }
                        setState(() {
                          currentIndex = key;
                        });
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    alignment: Alignment.center,
                    height: key != 2 ? 48 : 50,
                    width: key != 2 ? displayWidth * 15 : 50,
                    margin: EdgeInsets.only(
                        top: key != 2 ? 4 : 0,
                        left: key != 2 ? 0 : 8,
                        right: key != 2 ? 0 : 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(key != 2 ? 0 : 50)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        key == 2
                            ? SvgPicture.asset(
                                'assets/images/icons/Whistle.svg',
                                width: 32,
                                height: 32,
                                colorFilter: ColorFilter.mode(
                                    currentIndex == key
                                        ? ColorStyle.darkPurple
                                        : Colors.black,
                                    BlendMode.srcIn),
                              )
                            : Icon(
                                value,
                                size: key != 2
                                    ? currentIndex == key
                                        ? 26
                                        : 26
                                    : 24,
                                color: currentIndex == key
                                    ? ColorStyle.darkPurple
                                    : Colors.black,
                              ),
                        SizedBox(
                          height: key != 2 ? 0 : 0,
                        ),
                        Visibility(
                            visible: currentIndex == key,
                            child: Container(
                              width: 32,
                              height: 2.5,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                  color: ColorStyle.darkPurple,
                                  borderRadius: BorderRadius.circular(2)),
                            ))
                      ],
                    ),
                  ),
                )))
            .values
            .toList(),
      ),
    );
  }

  List<IconData> listOfIconsActive = [
    FeatherIcons.home,
    FeatherIcons.search,
    FeatherIcons.edit,
    FeatherIcons.bell,
    FeatherIcons.user
  ];

  List<String> listOfStrings = [
    'Inicio',
    'Buscar',
    'Agregar',
    'Alertas',
    'Perfil',
  ];
}
