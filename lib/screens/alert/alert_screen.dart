import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/repository/user_repository.dart';

class AlertScreen extends StatefulWidget {
  final UserRepository userRepository;

  const AlertScreen(this.userRepository);

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
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
                  top: Platform.isIOS ? 72 : 40,
                  bottom: 32),
              height: 56,
              decoration: BoxDecoration(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
