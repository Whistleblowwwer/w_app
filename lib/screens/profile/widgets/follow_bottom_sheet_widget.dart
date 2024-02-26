import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/profile/foreign_profile_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';

import 'package:flutter/material.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class FollowBottomSheetWidget extends StatefulWidget {
  final String userId;
  final String userMainId;
  final int? initialIndex;
  const FollowBottomSheetWidget(
      {super.key,
      required this.userId,
      this.initialIndex,
      required this.userMainId});

  @override
  State<FollowBottomSheetWidget> createState() =>
      _FollowBottomSheetWidgetState();
}

class _FollowBottomSheetWidgetState extends State<FollowBottomSheetWidget>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool isLoadingFollowers = true;
  List<User> followers = [];
  bool isLoadingFollowed = true;
  List<User> followed = [];
  late FeedBloc feedBloc;
  String userMainId = '';

  @override
  void initState() {
    super.initState();
    // Inicializa el TabController aquí
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex ?? 0);

    feedBloc = BlocProvider.of<FeedBloc>(context);

    loadFollowedByUser();
    loadFollowersByUser();
  }

  Future<void> loadFollowersByUser() async {
    try {
      var followerList = await ApiService().getFollowersByUser(widget.userId);

      if (mounted) {
        setState(() {
          followers = followerList;
          isLoadingFollowers = false;
        });
      }
    } catch (e) {
      // Handle the error or set state to show an error message
      if (mounted) {
        showErrorSnackBar(context, e.toString());
        setState(() {
          isLoadingFollowers = false;
        });
      }
    }
  }

  Future<void> loadFollowedByUser() async {
    try {
      var followedList = await ApiService().getFollowedByUser(widget.userId);

      if (mounted) {
        setState(() {
          followed = followedList;
          isLoadingFollowed = false;
        });
      }
    } catch (e) {
      // Handle the error or set state to show an error message
      if (mounted) {
        showErrorSnackBar(context, e.toString());
        setState(() {
          isLoadingFollowed = false;
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
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
                color: ColorStyle.borderGrey,
                borderRadius: BorderRadius.circular(12)),
          ),
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                height: 1.5, // Altura de la línea separadora
                alignment: Alignment.bottomCenter,
                color: ColorStyle.borderGrey, // Color de la línea separadora
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                overlayColor: MaterialStatePropertyAll(Colors.transparent),
                physics: const BouncingScrollPhysics(),
                unselectedLabelColor: Colors.grey,
                indicator: _customUnderlineIndicator(),
                indicatorColor: ColorStyle.darkPurple,
                indicatorWeight: 0,
                labelStyle: const TextStyle(
                    fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Seguidores'),
                  Tab(text: 'Seguidos'),
                ],
              ),
            ],
          ),
          Container(
            // Limitando el tamaño del TabBarView
            height: tabBarViewHeight,
            child: TabBarView(
              controller: _tabController,
              children: [
                CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      isLoadingFollowers
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
                          : followers.isEmpty
                              ? SliverToBoxAdapter(
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 96, left: 24, right: 24),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Aún no eres miembro de proyectos',
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
                                  padding: const EdgeInsets.only(
                                      bottom: 128, top: 16),
                                  sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                          childCount: followers
                                              .length, // número de items en la lista
                                          (BuildContext context, int index) {
                                    return GestureDetector(
                                        onTap: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ForeignProfileScreen(
                                                        followers[index])),
                                          );
                                        },
                                        child: Container(
                                          width: double.maxFinite,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                          decoration: const BoxDecoration(),
                                          child: Column(
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
                                                        '${followers[index].name[0].toUpperCase()}${followers[index].lastName[0].toUpperCase()}',
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
                                                            '${followers[index].userName!.isEmpty ? 'User$index' : followers[index].userName!}',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat'),
                                                          ),
                                                          Text(
                                                            '${followers[index].name} ${followers[index].lastName}',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
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
                                                    visible: widget
                                                            .userMainId !=
                                                        followers[index].idUser,
                                                    child: PressTransform(
                                                      onPressed: () {
                                                        _followUser(
                                                            followers[index]);
                                                        setState(() {});
                                                        print("0");
                                                      },
                                                      child: Container(
                                                        width: 104,
                                                        alignment:
                                                            Alignment.center,
                                                        margin: const EdgeInsets
                                                            .only(left: 16),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: ColorStyle
                                                                    .borderGrey)),
                                                        child: Text(
                                                          followers[index]
                                                                      .isFollowed ??
                                                                  false
                                                              ? "Siguiendo"
                                                              : "Seguir",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              color: followers[
                                                                              index]
                                                                          .isFollowed ??
                                                                      false
                                                                  ? ColorStyle
                                                                      .solidBlue
                                                                  : Colors
                                                                      .black,
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
                                                    top: 12,
                                                    bottom: 12,
                                                    left: 64),
                                                color: ColorStyle.borderGrey,
                                              )
                                            ],
                                          ),
                                        ));
                                  })))
                    ]),
                CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      isLoadingFollowed
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
                          : followed.isEmpty
                              ? SliverToBoxAdapter(
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 96, left: 24, right: 24),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Aún sigues a nadie',
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
                                  padding: const EdgeInsets.only(
                                      bottom: 128, top: 16),
                                  sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                          childCount: followed
                                              .length, // número de items en la lista
                                          (BuildContext context, int index) {
                                    return GestureDetector(
                                        onTap: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ForeignProfileScreen(
                                                        followed[index])),
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
                                                        '${followed[index].name[0].toUpperCase()}${followed[index].lastName[0].toUpperCase()}',
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
                                                            '${followed[index].userName!.isEmpty ? 'User$index' : followed[index].userName!}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat'),
                                                          ),
                                                          Text(
                                                            '${followed[index].name} ${followed[index].lastName}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
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
                                                    visible: widget
                                                            .userMainId !=
                                                        followed[index].idUser,
                                                    child: PressTransform(
                                                      onPressed: () {
                                                        _followUser(
                                                            followed[index]);
                                                        setState(() {});
                                                        print("0");
                                                      },
                                                      child: Container(
                                                        width: 104,
                                                        alignment:
                                                            Alignment.center,
                                                        margin: const EdgeInsets
                                                            .only(left: 16),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: ColorStyle
                                                                    .borderGrey)),
                                                        child: Text(
                                                          followed[index]
                                                                      .isFollowed ??
                                                                  false
                                                              ? "Siguiendo"
                                                              : "Seguir",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              color: followed[index]
                                                                          .isFollowed ??
                                                                      false
                                                                  ? ColorStyle
                                                                      .solidBlue
                                                                  : Colors
                                                                      .black,
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
                                                    top: 12,
                                                    bottom: 12,
                                                    left: 64),
                                                color: ColorStyle.borderGrey,
                                              )
                                            ],
                                          ),
                                        ));
                                  })))
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _followUser(User user) {
    // Actualiza el estado del usuario (seguido o no seguido)
    setState(() {
      // Actualiza la lista de seguidores con el nuevo estado
      followers = followers
          .map((r) => r.idUser == user.idUser
              ? r.copyWith(isFollowed: !r.isFollowed!)
              : r)
          .toList();

      followed = followed
          .map((r) => r.idUser == user.idUser
              ? r.copyWith(isFollowed: !r.isFollowed!)
              : r)
          .toList();

      // // // Revisa si el usuario ya es seguido tras el cambio y actúa en consecuencia
      // // bool isNowFollowed =
      // //     followers.firstWhere((r) => r.idUser == user.idUser).isFollowed ??
      // //         true;

      // // Si el usuario ahora es seguido, asegúrate de que esté en la lista followed
      // if (isNowFollowed) {
      //   bool alreadyFollowed = followed.any((r) => r.idUser == user.idUser);
      //   if (!alreadyFollowed) {
      //     followed.add(user.copyWith(isFollowed: true));
      //   }
      // } else {
      //   // Si el usuario ya no es seguido, elimínalo de la lista followed
      //   // followed.removeWhere((element) => element.idUser == user.idUser);
      // }
    });

    // Agrega el evento para seguir al usuario
    feedBloc.add(FollowUser(user.idUser));
  }

  UnderlineTabIndicator _customUnderlineIndicator() {
    return UnderlineTabIndicator(
      borderSide: const BorderSide(
          width: 1.5,
          color: ColorStyle.darkPurple), // Grosor y color del indicador
      insets: const EdgeInsets.fromLTRB(
          0.0, 0.0, 0.0, 0), // Ajusta el espacio a los lados y debajo del texto
    );
  }
}

// void _followUser(User user) {
//   // Actualiza el estado del usuario (seguido o no seguido)
//   setState(() {
//     // Primero, actualiza el estado de isFollowed en la lista de seguidores y seguidos
//     followers = followers.map((r) =>
//       r.idUser == user.idUser ? r.copyWith(isFollowed: !r.isFollowed) : r
//     ).toList();

//     // Verifica si el usuario ya está en la lista followed
//     bool isCurrentlyFollowed = followed.any((r) => r.idUser == user.idUser && r.isFollowed);

//     // Actualiza la lista followed
//     followed = followed.map((r) =>
//       r.idUser == user.idUser ? r.copyWith(isFollowed: !r.isFollowed) : r
//     ).toList();

//     // Si el usuario no estaba seguido antes y ahora lo está, lo añade a la lista
//     if (!isCurrentlyFollowed && user.isFollowed) {
//       followed.add(user.copyWith(isFollowed: true));
//     } else if (isCurrentlyFollowed && !user.isFollowed) {
//       // Si el usuario estaba seguido y ahora no lo está, lo elimina de la lista
//       followed.removeWhere((r) => r.idUser == user.idUser);
//     }
//   });

//   // Agrega el evento para seguir o dejar de seguir al usuario
//   feedBloc.add(FollowUser(user.idUser));
// }



    //  feedBloc.add(
            //                               FollowUser(notification.target.id));