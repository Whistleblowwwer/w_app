import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/chat/inbox_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class UserChatCard extends StatelessWidget {
  final String name;
  final String lastName;
  final String receiver;
  final String? photoUrl;
  final String initials;
  final String username;

  UserChatCard(
      {required this.name,
      required this.lastName,
      required this.receiver,
      required this.photoUrl,
      required this.initials,
      required this.username});

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    return GestureDetector(
      onTap: () async {
        //Obtiene el token
        String? tk = await UserRepository().getToken();
        if (tk != null) {
          //Sacar el token largo, el; corto ya esta
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              settings: RouteSettings(),
              builder: (context) => InboxScreen(
                  receiver: receiver,
                  receiverName: name + " " + lastName,
                  initials: initials)));
        } else {
          print("Token no provisto o no valido");
        }
      },
      child: Container(
        padding: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
        width: sizeW * 100,
        color: Colors.white,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularAvatarW(
                  externalRadius: Offset(56, 56),
                  internalRadius: Offset(48, 48),
                  sizeText: 24,
                  nameAvatar: name.substring(0, 1) + lastName.substring(0, 1),
                  isCompany: false),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name $lastName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      "@$username",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                      ),
                    )
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
