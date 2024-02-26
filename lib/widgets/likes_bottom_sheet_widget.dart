import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/profile/foreign_profile_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

enum PostType {
  review,
  comment,
}

class LikesBottomSheetWidget extends StatefulWidget {
  final String id;
  final PostType postType;
  final String userMain;
  final int? initialIndex;
  const LikesBottomSheetWidget(
      {super.key,
      required this.id,
      required this.postType,
      this.initialIndex,
      required this.userMain});

  @override
  State<LikesBottomSheetWidget> createState() => _LikesBottomSheetWidgetState();
}

class _LikesBottomSheetWidgetState extends State<LikesBottomSheetWidget>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool isLoadinglikes = true;
  List<User> likes = [];

  late FeedBloc feedBloc;

  @override
  void initState() {
    super.initState();
    // Inicializa el TabController aquí
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex ?? 0);
    feedBloc = BlocProvider.of<FeedBloc>(context);

    loadLikesByPost();
  }

  Future<void> loadLikesByPost() async {
    try {
      var likesList =
          await ApiService().getLikesByPost(widget.id, widget.postType);

      if (mounted) {
        setState(() {
          likes = likesList;
          isLoadinglikes = false;
        });
      }
    } catch (e) {
      // Handle the error or set state to show an error message
      if (mounted) {
        // showErrorSnackBar(context, e.toString());
        setState(() {
          isLoadinglikes = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se puede ajustar esta altura para controlar cuánto espacio quieres que ocupe el BottomSheet
    final double tabBarViewHeight = MediaQuery.of(context).size.height * 0.87;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 6,
            margin: EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
                color: ColorStyle.borderGrey,
                borderRadius: BorderRadius.circular(12)),
          ),
          Text(
            "Me gusta",
            style: TextStyle(
                fontFamily: 'Monserrat',
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                height: 0.6, // Altura de la línea separadora
                margin: EdgeInsets.only(top: 8),
                alignment: Alignment.bottomCenter,
                color: ColorStyle.borderGrey, // Color de la línea separadora
              ),
            ],
          ),
          Container(
            // Limitando el tamaño del TabBarView
            height: tabBarViewHeight,
            child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  isLoadinglikes
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 96),
                            child: Center(
                                child: CircularProgressIndicator.adaptive(
                              backgroundColor:
                                  ColorStyle.grey, // Fondo del indicador
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorStyle.darkPurple),
                            )),
                          ),
                        )
                      : likes.isEmpty
                          ? const SliverToBoxAdapter(
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 96, left: 24, right: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Aún no hay interacción',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  )),
                            )
                          : SliverPadding(
                              padding:
                                  const EdgeInsets.only(bottom: 128, top: 16),
                              sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                      childCount: likes
                                          .length, // número de items en la lista
                                      (BuildContext context, int index) {
                                return GestureDetector(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ForeignProfileScreen(
                                                    likes[index])),
                                      );
                                    },
                                    child: Container(
                                      width: double.maxFinite,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      decoration: const BoxDecoration(),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              CircularAvatarW(
                                                externalRadius:
                                                    const Offset(38, 38),
                                                internalRadius:
                                                    const Offset(34, 34),
                                                nameAvatar:
                                                    '${likes[index].name[0].toUpperCase()}${likes[index].lastName[0].toUpperCase()}',
                                                isCompany: false,
                                                sizeText: 16,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Flexible(
                                                child: SizedBox(
                                                  width: double.maxFinite,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${likes[index].userName!.isEmpty ? 'User$index' : likes[index].userName!}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                      Text(
                                                        '${likes[index].name} ${likes[index].lastName}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: ColorStyle
                                                                .textGrey,
                                                            fontSize: 13,
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: likes[index].idUser !=
                                                    widget.userMain,
                                                child: PressTransform(
                                                  onPressed: () {
                                                    _followUser(likes[index]);
                                                    setState(() {});
                                                    print("0");
                                                  },
                                                  child: Container(
                                                    width: 104,
                                                    alignment: Alignment.center,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 16),
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: ColorStyle
                                                                .borderGrey)),
                                                    child: Text(
                                                      likes[index].isFollowed ??
                                                              false
                                                          ? "Siguiendo"
                                                          : "Seguir",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: likes[index]
                                                                      .isFollowed ??
                                                                  false
                                                              ? ColorStyle
                                                                  .solidBlue
                                                              : Colors.black,
                                                          fontFamily:
                                                              'Montserrat'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 16,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: double.maxFinite,
                                            height: 0.5,
                                            margin: EdgeInsets.only(
                                                top: 12, bottom: 12, left: 64),
                                            color: ColorStyle.borderGrey,
                                          )
                                        ],
                                      ),
                                    ));
                              })))
                ]),
          ),
        ],
      ),
    );
  }

  void _followUser(User user) {
    // Actualiza el estado del usuario (seguido o no seguido)
    setState(() {
      // Actualiza la lista de seguidores con el nuevo estado
      likes = likes
          .map((r) => r.idUser == user.idUser
              ? r.copyWith(isFollowed: !r.isFollowed!)
              : r)
          .toList();
    });

    // Agrega el evento para seguir al usuario
    feedBloc.add(FollowUser(user.idUser));
  }
}
