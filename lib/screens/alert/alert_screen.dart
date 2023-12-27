import 'package:flutter/material.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/styles/color_style.dart';

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
                  return Column(
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: ColorStyle.lightGrey,
                          child: true
                              ? Image.asset(
                                  'assets/images/logos/imagew.png',
                                  width: 32,
                                )
                              : const Text(
                                  "W",
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                        trailing: const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Icon(
                            Icons.more_horiz,
                            size: 28,
                          ),
                        ),
                        title: const Text(
                          "Whistleblowwer",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                        subtitle: const Column(
                          children: [
                            Text(
                              "Conoce todo lo que la aplicacion de Whistleblowwer te puede ofrecer",
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.date_range,
                                    size: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "22 min",
                                  style: TextStyle(
                                      fontSize: 12, fontFamily: 'Montserrat'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Divider(
                          height: 0,
                          color: ColorStyle.borderGrey,
                          thickness: 0.4,
                          // indent: 16,
                          // endIndent: 16,
                        ),
                      )
                    ],
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
