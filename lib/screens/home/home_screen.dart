import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';

class HomeScreen extends StatefulWidget {
  final UserRepository userRepository;

  const HomeScreen(this.userRepository);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await widget.userRepository.deleteToken();
      _userBloc = BlocProvider.of<UserBloc>(context);
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
          decodedToken['id']; // Asume que el ID está bajo la clave 'id'
      _userBloc.add(FetchUserProfile(token, userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: Platform.isIOS ? 64 : 40,
                  bottom: 0),
              height: 12,
              decoration: BoxDecoration(color: null),
            ),
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 256),
                  child: Column(
                    children: List.generate(
                      15,
                      (index) => ReviewCard(),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
