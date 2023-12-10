import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_state.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/screens/chat/inbox_screen.dart';
import 'package:w_app/screens/chat/widgets/chat_card.dart';
import 'package:w_app/services/api/api_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  _ChatPageState();
  dynamic conversations = [];
  Map<String, dynamic> rsp = {};

  @override
  void initState() {
    loadChats();
    super.initState();
  }

  Future<void> loadChats() async {
    Map<String, dynamic> user = await ApiService().getUserProfile();
    dynamic conv = await ApiService().getChats();
    setState(() {
      conversations = conv;
      rsp = user;
    });
    print(conv);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Mis chats'),
          centerTitle: true,
        ),
        body: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Column(children: [
              Flexible(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (conversations[index]['Sender']['_id_user'] ==
                        rsp['user']['_id_user']) {
                      return ChatCard(
                          name:
                              "${conversations[index]['Receiver']['name']} ${conversations[index]['Receiver']['last_name']}",
                          lastMessage:
                              "${conversations[index]['Message']['content']}",
                          lastMessageTime:
                              "${conversations[index]['Message']['createdAt']}",
                          photoUrl:
                              "${conversations[index]['Receiver']['profile_picture_url']}",
                          receiver:
                              "${conversations[index]['Receiver']['_id_user']}");
                    } else {
                      return ChatCard(
                          name:
                              "${conversations[index]['Sender']['name']} ${conversations[index]['Sender']['last_name']}",
                          lastMessage:
                              "${conversations[index]['Message']['content']}",
                          lastMessageTime:
                              "${conversations[index]['Message']['createdAt']}",
                          photoUrl:
                              "${conversations[index]['Sender']['profile_picture_url']}",
                          receiver:
                              "${conversations[index]['Sender']['_id_user']}");
                    }
                  },
                  itemCount: conversations.length,
                ),
              )
            ])));
  }
}
