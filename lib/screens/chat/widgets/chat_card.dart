import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/chat/inbox_screen.dart';
import 'package:w_app/services/api/api_service.dart';


class ChatCard extends StatelessWidget{
  final String name;
  final String lastMessage;
  final String lastMessageTime;
  final String photoUrl;
  final String receiver;

  ChatCard({
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.photoUrl,
    required this.receiver,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        onTap:  () async {
          //Obtiene el token
          String? tk= await UserRepository().getToken();
          if(tk!=null){
            //Sacar el token largo, el; corto ya esta
            Navigator.of(context,rootNavigator: true).push(
              MaterialPageRoute(
                settings: RouteSettings(),
                builder: (context) => InboxScreen(receiver: receiver,token:'$tk')
              )
            );
          }else{
            print("Token no provisto o no valido");
          }
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(photoUrl),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  lastMessage,
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  lastMessageTime.substring(11, 16),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            Spacer()
          ]
        )
      ),
    );
  }

  
}