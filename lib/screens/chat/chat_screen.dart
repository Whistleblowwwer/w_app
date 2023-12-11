import 'package:flutter/material.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/chat/widgets/chat_card.dart';
import 'package:w_app/services/api/api_service.dart';

class ChatPage extends StatefulWidget {
  final User user;
  ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  _ChatPageState();
  dynamic conversations = [];

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  void initState() {
    loadChats();
    super.initState();
  }

  Future<void> loadChats() async {
    dynamic conv = await ApiService().getChats();
    if (!mounted) return;
    setState(() {
      conversations = conv;
    });
    print(conv);
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Mensajes',
            style: TextStyle(
                fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: SizedBox(
            width: sizeW * 100,
            height: double.maxFinite,
            child: Column(children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (conversations[index]['Sender']['_id_user'] ==
                        widget.user.idUser) {
                      return ChatCard(
                          name: "${conversations[index]['Receiver']['name']}",
                          lastName:
                              "${conversations[index]['Receiver']['last_name']}",
                          lastMessage:
                              "Tú: ${conversations[index]['Message']['content']}",
                          lastMessageTime:
                              "${conversations[index]['Message']['createdAt']}",
                          photoUrl:
                              "${conversations[index]['Receiver']['profile_picture_url']}",
                          receiver:
                              "${conversations[index]['Receiver']['_id_user']}");
                    } else {
                      return ChatCard(
                          name: "${conversations[index]['Sender']['name']}",
                          lastName:
                              "${conversations[index]['Sender']['last_name']}",
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
