import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:uni_links/uni_links.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/feed_bloc/feed_state.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/actions/comment_bottom_sheet.dart';
import 'package:w_app/screens/home/assitants_screen.dart';
import 'package:w_app/screens/home/lawyers_screen.dart';
import 'package:w_app/screens/chat/chat_screen.dart';
import 'package:w_app/screens/home/review_screen.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class HomeScreen extends StatefulWidget {
  final UserRepository userRepository;

  const HomeScreen(this.userRepository);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserBloc _userBloc;
  late FeedBloc _feedBloc;
  late Future<List<dynamic>> futureReview;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    futureReview = ApiService().getReviews();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _feedBloc = BlocProvider.of<FeedBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _feedBloc.add(InitialFeedReviews());
    });

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {}
    });

    initUniLinks();
  }

  Future<void> initUniLinks() async {
    // Escucha los enlaces entrantes
    _sub = linkStream.listen((String? link) async {
      print("Enlace recibido: $link");
      if (link != null) {
        // Primero, verifica si es un enlace de review
        if (isReviewLink(link)) {
          // Extrae el ID del review del enlace
          final String? reviewId = extractReviewId(link);
          if (reviewId != null) {
            // Si es un enlace de review, navega a la pantalla de Review
            try {
              final review = await ApiService().getReview(reviewId);
              if (mounted) {
                Navigator.of(context).push(MaterialPageRoute(
                  settings: const RouteSettings(),
                  builder: (context) => ReviewPage(
                      review: review,
                      isUniqueRoute: true,
                      onLike: () {
                        _feedBloc.add(LikeReview(review));
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
                                        name: review.user.name,
                                        lastName: review.user.lastName,
                                        content: review.content,
                                        images: review.images,
                                      ));

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

                                  print(imagesResponse.statusCode);

                                  if (imagesResponse.statusCode == 201 ||
                                      imagesResponse.statusCode == 200) {
                                    print(imagesResponse.body);
                                    final jsonImageResponse =
                                        json.decode(imagesResponse.body);

                                    print(jsonImageResponse);

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

                              _feedBloc.add(AddComment(
                                  comment: responseComment,
                                  reviewId: review.idReview));

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
                      onFollowUser: () {
                        _feedBloc.add(FollowUser(review.user.idUser));
                      },
                      onFollowBusiness: () {
                        _feedBloc.add(
                            FollowBusiness(review.business?.idBusiness ?? ''));
                      }),
                ));
              }
            } catch (e) {}
          }
        } else {
          // Aquí puedes manejar otros tipos de enlaces
          print("El enlace no es de un review.");
        }
      }
    }, onError: (err) {
      // Maneja el error
    });
  }

  // Mejora de la función para verificar si es un enlace de review
  bool isReviewLink(String link) {
    final Uri? uri = Uri.tryParse(link);
    // Verifica si el URI es válido y si el enlace corresponde a un review
    return uri != null &&
        uri.host == 'www.whistleblowwer.com' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == 'review';
  }

// Función para extraer el ID del review de un enlace
  String? extractReviewId(String link) {
    if (isReviewLink(link)) {
      final Uri uri = Uri.parse(link);
      // Suponiendo que el ID siempre sigue después del segmento 'review'
      return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    }
    return null;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // No olvides deshacerte del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 56,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding:
                      const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                              color: ColorStyle.borderGrey, width: 0.3))),
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
                          PressTransform(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const LawyersScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                  color: ColorStyle.sectionBase,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text(
                                "Abogados",
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          PressTransform(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AssistantScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                  color: ColorStyle.sectionBase,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text(
                                "Asesores",
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final userState = _userBloc.state;
                              if (userState is UserLoaded) {
                                Navigator.of(context, rootNavigator: true)
                                    .push(MaterialPageRoute(
                                        settings: const RouteSettings(),
                                        builder: (context) => ChatPage(
                                              user: userState.user,
                                            )));
                              }
                            },
                            child: Stack(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 2),
                                  child: Icon(
                                    FeatherIcons.mail,
                                    size: 26,
                                  ),
                                ),
                                // Positioned(
                                //   top: 0,
                                //   right: 0,
                                //   child: Container(
                                //       width: 14,
                                //       height: 12,
                                //       alignment: Alignment.center,
                                //       decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(20),
                                //         color: ColorStyle.darkPurple,
                                //       ),
                                //       child: const Text(
                                //         "1",
                                //         style: TextStyle(
                                //             fontFamily: 'Montserrat',
                                //             fontSize: 10,
                                //             color: Colors.white,
                                //             fontWeight: FontWeight.w600),
                                //       )),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ];
        },
        body: RefreshIndicator.adaptive(
          color: ColorStyle.darkPurple,
          backgroundColor: ColorStyle.grey,
          onRefresh: () async {
            _feedBloc.add(FetchFeedReviews());
            await Future.delayed(const Duration(milliseconds: 1200));
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              BlocBuilder<FeedBloc, FeedState>(
                builder: (context, state) {
                  if (state is FeedLoaded) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: state.reviews.length +
                            1, // El total de elementos en tu lista
                        (BuildContext context, int index) {
                          if (index < state.reviews.length) {
                            return ReviewCard(
                              review: state.reviews[index],
                              onFollowUser: () async {
                                _feedBloc.add(FollowUser(
                                    state.reviews[index].user.idUser));
                              },
                              onFollowBusinnes: () {
                                _feedBloc.add(FollowBusiness(
                                    state.reviews[index].business!.idBusiness));
                              },
                              onLike: () {
                                _feedBloc.add(LikeReview(state.reviews[index]));
                              },
                              onDelete: () async {
                                try {
                                  final response = await ApiService()
                                      .deleteReview(
                                          state.reviews[index].idReview);
                                  if (response == 200) {
                                    _feedBloc.add(DeleteReview(
                                        state.reviews[index].idReview));
                                    if (mounted) {
                                      showSuccessSnackBar(context,
                                          message:
                                              "Se elimino la reseña exitosamente");
                                    }
                                  } else {
                                    if (mounted) {
                                      showErrorSnackBar(context,
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
                                final userState = _userBloc.state;
                                if (userState is UserLoaded) {
                                  Map<String, dynamic>? response =
                                      await showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          useRootNavigator: true,
                                          barrierColor: const Color.fromRGBO(
                                              0, 0, 0, 0.1),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.0),
                                              topRight: Radius.circular(20.0),
                                            ),
                                          ),
                                          builder: (context) =>
                                              CommentBottomSheet(
                                                user: userState.user,
                                                name: state
                                                    .reviews[index].user.name,
                                                lastName: state.reviews[index]
                                                    .user.lastName,
                                                content: state
                                                    .reviews[index].content,
                                                images:
                                                    state.reviews[index].images,
                                              ));

                                  if (response != null) {
                                    try {
                                      final responseComment = await ApiService()
                                          .commentReview(
                                              content: response['content'],
                                              idReview: state
                                                  .reviews[index].idReview);

                                      if (mounted) {
                                        showSuccessSnackBar(context);
                                      }

                                      try {
                                        if (response['images'] != null) {
                                          final imagesResponse =
                                              await ApiService()
                                                  .uploadCommentImages(
                                            responseComment.idComment,
                                            response['images'],
                                          );

                                          print(imagesResponse.statusCode);

                                          if (imagesResponse.statusCode ==
                                                  201 ||
                                              imagesResponse.statusCode ==
                                                  200) {
                                            print(imagesResponse.body);
                                            final jsonImageResponse = json
                                                .decode(imagesResponse.body);

                                            print(jsonImageResponse);

                                            // Convierte cada elemento de la lista a una cadena (String)
                                            List<String> dynamicList =
                                                List<String>.from(
                                                    jsonImageResponse['Images']
                                                        .map((e) =>
                                                            e.toString()));

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

                                      _feedBloc.add(AddComment(
                                          comment: responseComment,
                                          reviewId:
                                              state.reviews[index].idReview));

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
                          } else {
                            return SizedBox(
                              height: 96,
                            );
                            // return const Padding(
                            //   padding: EdgeInsets.only(top: 32, bottom: 128),
                            //   child: CircularProgressIndicator.adaptive(
                            //     backgroundColor:
                            //         ColorStyle.grey, // Fondo del indicador
                            //     valueColor: AlwaysStoppedAnimation<Color>(
                            //         ColorStyle.darkPurple),
                            //   ),
                            // );
                          }
                        },
                      ),
                    );
                  } else if (state is FeedLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(
                            child: CircularProgressIndicator.adaptive(
                          backgroundColor:
                              ColorStyle.grey, // Fondo del indicador
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorStyle.darkPurple),
                        )),
                      ),
                    );
                  } else if (state is FeedError) {
                    return SliverToBoxAdapter(
                      child: Column(
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
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            'Parece que hubo un error\n${state.error.toString()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SliverToBoxAdapter();
                  }
                },
              ),
              // Puedes agregar más Slivers si necesitas
            ],
          ),
        ),
      ),
    );
  }
}
