import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/repository/user_repository.dart';
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
  late Future<List<Review>> futureReview;

  @override
  void initState() {
    super.initState();
    futureReview = ApiService().getReviews();
    _userBloc = BlocProvider.of<UserBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await widget.userRepository.deleteToken();

      // _fetchUserProfile();
    });
  }

  Future<void> _fetchUserProfile() async {
    // await widget.userRepository.deleteToken();

    final token = await widget.userRepository.getToken();
    if (token != null) {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print(decodedToken);
      final String userId =
          decodedToken['_id_user']; // Asume que el ID está bajo la clave 'id'

      _userBloc.add(FetchUserProfile(token, userId));
    }
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
                                color: ColorStyle().lightGrey,
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
                                color: ColorStyle().lightGrey,
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
                    child: FutureBuilder(
                        future: futureReview,
                        builder:
                            (context, AsyncSnapshot<List<Review>> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Padding(
                                padding: EdgeInsets.only(top: 32),
                                child: Center(
                                    child:
                                        CircularProgressIndicator.adaptive()),
                              );
                              ;
                            case ConnectionState.done:
                              if (snapshot.hasError) {
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
                                      'Parece que hubo un error\n${snapshot.error.toString()}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 256,
                                    ),
                                    Text(
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
                                      'Parece que no hay data',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                );
                              } else {
                                return SingleChildScrollView(
                                  padding:
                                      EdgeInsets.only(top: 32, bottom: 256),
                                  child: Column(
                                    children: List.generate(
                                      snapshot.data!.length,
                                      (index) => ReviewCard(
                                        review: snapshot.data![index],
                                      ),
                                    ),
                                  ),
                                );
                              }

                            default:
                              return Container();
                          }
                        }),
                  ),
                )
              ],
            ),
            Positioned(
              right: 16,
              bottom: 120,
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
                  backgroundColor: ColorStyle().darkPurple),
            )
          ],
        ),
      ),
    );
  }
}
