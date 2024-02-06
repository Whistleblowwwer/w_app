import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';

class AlertScreen extends StatefulWidget {
  final UserRepository userRepository;

  const AlertScreen(this.userRepository);

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  // late UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await widget.userRepository.deleteToken();
      // _userBloc = BlocProvider.of<UserBloc>(context);
      // _fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final sizeW = MediaQuery.of(context).size.width / 100;
    // final sizeH = MediaQuery.of(context).size.height / 100;
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          children: [
            const SizedBox(
              height: 88,
            ),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 8, left: 24),
                    child: Container(
                      alignment: Alignment.center,
                      width: 32,
                      height: 24,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: ColorStyle.darkPurple.withOpacity(0.2)),
                      child: const Text(
                        "1",
                        style: TextStyle(
                            color: ColorStyle.darkPurple,
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                const Text(
                  "Notificaciones",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 24),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 24),
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.maxFinite,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  width: 44,
                                ),
                                CircularAvatarW(
                                    externalRadius: Offset(40, 40),
                                    internalRadius: Offset(36, 36),
                                    nameAvatar: "W",
                                    sizeText: 17,
                                    isCompany: false),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index == 0
                                            ? Colors.indigoAccent
                                            : Colors.redAccent,
                                        border: Border.all(
                                            color: Colors.white, width: 2)),
                                    child: Icon(
                                      index == 0
                                          ? Icons.person
                                          : Icons.favorite,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                )
                              ],
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
                                        child: Text(
                                          index == 0
                                              ? "Whistleblowwer"
                                              : "Jorge Ancer",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      // Text(
                                      //   "  22 min",
                                      //   style: TextStyle(
                                      //       fontSize: 14,
                                      //       fontWeight: FontWeight.w500,
                                      //       fontFamily: 'Montserrat',
                                      //       color: ColorStyle.textGrey),
                                      // ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    index == 0
                                        ? "Publico su primer hilo"
                                        : "Conoce todo lo que la aplicacion de Whistleblowwer te puede ofrecer",
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: ColorStyle.textGrey),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Visibility(
                                    visible: index == 0,
                                    child: Text(
                                      "Conoce todo lo que la aplicacion de Whistleblowwer te puede ofrecer",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  // Row(
                                  //   children: [
                                  //     Padding(
                                  //       padding: EdgeInsets.only(right: 4),
                                  //       child: Icon(
                                  //         Icons.date_range,
                                  //         size: 13,
                                  //         color: Colors.grey,
                                  //       ),
                                  //     ),

                                  //   ],
                                  // )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 1,
                        margin: EdgeInsets.only(top: 16, bottom: 16),
                        color: ColorStyle.borderGrey,
                      )
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
