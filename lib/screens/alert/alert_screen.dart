import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/notification_model.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/chat/inbox_screen.dart';
import 'package:w_app/screens/home/comment_screen.dart';
import 'package:w_app/screens/home/review_screen.dart';
import 'package:w_app/screens/profile/foreign_profile_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class AlertScreen extends StatefulWidget {
  final UserRepository userRepository;

  const AlertScreen(this.userRepository);

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  late FeedBloc feedBloc;
  List<UserNotification> history = [];
  bool isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    feedBloc = BlocProvider.of<FeedBloc>(context);

    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final businessList = await ApiService().getNotificationHistory();
      print(businessList);
      print("ssaaa");

      if (mounted) {
        setState(() {
          history = businessList;
          isLoadingHistory = false;
        });
      }
    } catch (e) {
      // Handle the error or set state to show an error message
      if (mounted) {
        showErrorSnackBar(context, e.toString());
        setState(() {
          isLoadingHistory = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final sizeW = MediaQuery.of(context).size.width / 100;
    // final sizeH = MediaQuery.of(context).size.height / 100;
    return Scaffold(
      body: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(right: 8, left: 24),
                  //   alignment: Alignment.center,
                  //   width: 32,
                  //   height: 24,
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(24),
                  //       color: ColorStyle.darkPurple.withOpacity(0.2)),
                  //   child: const Text(
                  //     "1",
                  //     style: TextStyle(
                  //         color: ColorStyle.darkPurple,
                  //         fontFamily: 'Montserrat',
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                  const Text(
                    "Actividad",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 26),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator.adaptive(
                displacement: 48,
                edgeOffset: 16,
                color: ColorStyle.darkPurple,
                backgroundColor: ColorStyle.grey,
                onRefresh: () async {
                  await loadHistory();
                  Future.delayed(const Duration(milliseconds: 1000));
                },
                child: CustomScrollView(
                  slivers: [
                    isLoadingHistory
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 296),
                              child: Center(
                                  child: CircularProgressIndicator.adaptive(
                                backgroundColor:
                                    ColorStyle.grey, // Fondo del indicador
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    ColorStyle.darkPurple),
                              )),
                            ),
                          )
                        : history.isEmpty
                            ? const SliverToBoxAdapter(
                                child: Padding(
                                    padding: EdgeInsets.only(top: 296),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'No tienes notificaciones',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    )),
                              )
                            : SliverPadding(
                                padding:
                                    const EdgeInsets.only(top: 24, bottom: 96),
                                sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                        childCount: history
                                            .length, // número de items en la lista
                                        (BuildContext context, int index) {
                                  UserNotification notification =
                                      history[index];
                                  return NotificationWidget(
                                    notification: notification,
                                    onFollowUser: () {
                                      _toggleFollowStatus(
                                          notification.idUserSender);
                                      feedBloc.add(
                                          FollowUser(notification.target.id));
                                    },
                                    onTap: () async {
                                      try {
                                        if (notification.type == "profile") {
                                          final user = await ApiService()
                                              .getProfileDetail(
                                                  notification.target.id);
                                          if (mounted) {
                                            Navigator.of(context,
                                                    rootNavigator: false)
                                                .push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ForeignProfileScreen(
                                                          user)),
                                            );
                                          }
                                        } else if (notification.type ==
                                            "review") {
                                          final review = await ApiService()
                                              .getReview(
                                                  notification.target.id);
                                          print(review);
                                          if (mounted) {
                                            Navigator.of(context,
                                                    rootNavigator: false)
                                                .push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReviewPage(
                                                          review: review,
                                                          onLike: () {},
                                                          onComment:
                                                              () async {},
                                                          onFollowUser: () {},
                                                          onFollowBusiness:
                                                              () {})),
                                            );
                                          }
                                        } else if (notification.type ==
                                            "comment") {
                                          final userBlocState =
                                              BlocProvider.of<UserBloc>(context)
                                                  .state;
                                          if (userBlocState is UserLoaded) {
                                            final comment = await ApiService()
                                                .getComment(
                                                    notification.target.id);
                                            if (mounted) {
                                              Navigator.of(context,
                                                      rootNavigator: false)
                                                  .push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommentPage(
                                                          comment: comment,
                                                          onLike: () {},
                                                          onComment:
                                                              () async {},
                                                          onFollowUser: () {},
                                                          user: userBlocState
                                                              .user,
                                                        )),
                                              );
                                            }
                                          }
                                        } else if (notification.type ==
                                            "chat") {
                                          String? tk =
                                              await UserRepository().getToken();
                                          if (tk != null) {
                                            if (mounted) {
                                              final userBlocState =
                                                  BlocProvider.of<UserBloc>(
                                                          context)
                                                      .state;
                                              if (userBlocState is UserLoaded) {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .push(MaterialPageRoute(
                                                        settings:
                                                            const RouteSettings(),
                                                        builder: (context) => InboxScreen(
                                                            receiver:
                                                                notification
                                                                    .idUserSender,
                                                            receiverName:
                                                                "${notification.target.name} ${notification.target.lastName}",
                                                            initials: userBlocState
                                                                    .user
                                                                    .name[0] +
                                                                userBlocState
                                                                        .user
                                                                        .lastName[
                                                                    0])));
                                              }
                                            }
                                          } else {
                                            print(
                                                "Token no provisto o no valido");
                                          }
                                        } else if (notification.type ==
                                            "business") {
                                          final review = await ApiService()
                                              .getReview(
                                                  notification.target.id);
                                          if (mounted) {
                                            Navigator.of(context,
                                                    rootNavigator: false)
                                                .push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReviewPage(
                                                          review: review,
                                                          onLike: () {},
                                                          onComment:
                                                              () async {},
                                                          onFollowUser: () {},
                                                          onFollowBusiness:
                                                              () {})),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    onSenderTap: () async {
                                      if (notification.type == "profile" ||
                                          notification.type == "review" ||
                                          notification.type == "comment" ||
                                          notification.type == "chat") {
                                        final user = await ApiService()
                                            .getProfileDetail(
                                                notification.idUserSender);
                                        if (mounted) {
                                          Navigator.of(context,
                                                  rootNavigator: false)
                                              .push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ForeignProfileScreen(user)),
                                          );
                                        }
                                      }
                                    },
                                  );
                                })))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFollowStatus(String userSenderId) {
    // Primero, determina el estado de seguimiento actual para el primer elemento encontrado que coincida con el userSenderId.
    // Asumiremos que todos los elementos con el mismo userSenderId tienen el mismo estado de seguimiento.
    final bool? currentFollowStatus = history
        .firstWhere(
          (notification) => notification.idUserSender == userSenderId,
        )
        .target
        .isFollowed;

    // Si no encontramos una notificación con ese userSenderId, no hacemos nada.
    if (currentFollowStatus == null) return;

    // Calcula el nuevo estado de seguimiento como la inversa del actual.
    final bool newFollowStatus = !currentFollowStatus;

    // Itera sobre la lista y actualiza todas las notificaciones con ese userSenderId.
    final List<UserNotification> updatedHistory = history.map((notification) {
      if (notification.idUserSender == userSenderId) {
        // Si el idUserSender coincide, actualiza el estado de isFollowed del Target.
        return notification.copyWith(
          target: notification.target.copyWith(
            isFollowed: newFollowStatus,
          ),
        );
      }
      return notification; // Si no coincide, devuelve la notificación sin cambios.
    }).toList();

    // Actualiza la lista de notificaciones en el estado con la lista actualizada.
    setState(() {
      history = updatedHistory;
    });
  }
}

class NotificationWidget extends StatelessWidget {
  final UserNotification notification;
  final VoidCallback? onFollowUser;
  final VoidCallback onSenderTap;
  final VoidCallback onTap;

  NotificationWidget(
      {super.key,
      required this.notification,
      this.onFollowUser,
      required this.onSenderTap,
      required this.onTap});

  // Mapa de tipos de notificaciones a colores
  final Map<String, Color> notificationColors = {
    "profile": Colors.indigoAccent,
    "review": Colors.redAccent,
    "comment": Colors.lightBlueAccent,
    "chat": Colors.deepPurpleAccent,
    "business": Colors.pinkAccent,
    // Valor por defecto

    "default": Colors.pinkAccent,
  };

  // Mapa de tipos de notificaciones a íconos
  final Map<String, IconData> notificationIcons = {
    "profile": Icons.person,
    "review": Icons.favorite,
    "comment": Icons.reply,
    "chat": Icons.mail_rounded,
    "business": Icons.notifications,
    // Valor por defecto
    "default": Icons.notifications,
  };

  // Función para obtener el color basado en el tipo de notificación
  Color _getColorForNotification(String type) {
    return notificationColors[type] ?? notificationColors["default"]!;
  }

  // Función para obtener el ícono basado en el tipo de notificación
  IconData _getIconForNotification(String type) {
    return notificationIcons[type] ?? notificationIcons["default"]!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          color: Colors.transparent,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      onSenderTap();
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 44,
                        ),
                        CircularAvatarW(
                            externalRadius: Offset(40, 40),
                            internalRadius: Offset(36, 36),
                            nameAvatar:
                                notification.target.name[0].toUpperCase(),
                            sizeText: 20,
                            isCompany: false),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _getColorForNotification(notification.type),
                                border: Border.all(
                                    color: Colors.white, width: 1.5)),
                            child: notification.type == "business"
                                ? SvgPicture.asset(
                                    'assets/images/icons/Whistle.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  )
                                : Icon(
                                    _getIconForNotification(notification.type),
                                    color: Colors.white,
                                    size: 10,
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  onSenderTap();
                                },
                                child: Text(
                                  '${notification.target.name} ${notification.target.lastName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            Text(
                              "  ${notification.getRelativeTime()}",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  color: ColorStyle.textGrey),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          notification.subject,
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: ColorStyle.textGrey),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Visibility(
                          visible: notification.content.isNotEmpty,
                          child: Text(
                            notification.content,
                            style: TextStyle(
                                fontFamily: 'Montserrat', color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: notification.type == "profile",
                    child: PressTransform(
                      onPressed: () {
                        onFollowUser!();
                        print("0");
                      },
                      child: Container(
                        width: 104,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 16),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ColorStyle.borderGrey)),
                        child: Text(
                          notification.target.isFollowed ?? false
                              ? "Siguiendo"
                              : "Seguir",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: notification.target.isFollowed ?? false
                                  ? ColorStyle.solidBlue
                                  : Colors.black,
                              fontFamily: 'Montserrat'),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 0.5,
              margin: EdgeInsets.only(top: 16, bottom: 16, left: 64),
              color: ColorStyle.borderGrey,
            )
          ]),
        ));
  }
}
