import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/add/add_review.dart';
import 'package:w_app/screens/alert/alert_screen.dart';
import 'package:w_app/screens/home/home_screen.dart';
import 'package:w_app/screens/profile/profile_screen.dart';
import 'package:w_app/screens/search/search_screen.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

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
        _fetchUserProfile();
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

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width / 100;
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserTokenError) {
          _authBloc.add(LogOutUser());
        } else if (state is UserLoaded) {}
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color.fromRGBO(226, 226, 226, 1),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
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
      height: 88,
      padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
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
