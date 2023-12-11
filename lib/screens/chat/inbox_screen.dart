import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:socket_io_common/src/util/event_emitter.dart';
import 'package:w_app/screens/chat/widgets/message_cont.dart';
import 'package:w_app/services/api/api_service.dart';

class InboxScreen extends StatefulWidget {
  final String receiver;
  final String token;

  InboxScreen({
    required this.receiver,
    required this.token,
  });

  @override
  State<InboxScreen> createState() => _InboxScreenState(receiver, token);
}

class _InboxScreenState extends State<InboxScreen> {
  // final _keyboardVisibilityController = KeyboardVisibilityController();
  TextEditingController _textFieldController = TextEditingController();

  List<MessageContainer> messages = [];
  String msg = "";
  late IO.Socket socket;
  String token;
  String receiver;
  Map<String, dynamic> user = {};

  _InboxScreenState(this.receiver, this.token);

  Future<void> loadMessages() async {
    List<dynamic> msg = await ApiService().getConversationMessages(receiver);
    Map<String, dynamic> rsp = await ApiService().getUserProfile();
    List<MessageContainer> messageContainers = [];
    for (int i = msg.length - 1; i >= 0; i--) {
      bool mine = false;
      if (msg[i]['Sender']['_id_user'] == rsp['user']['_id_user']) {
        mine = true;
      }
      messageContainers.add(MessageContainer(
          message: msg[i]['content'],
          isMine: mine,
          date: DateTime.parse(msg[i]['createdAt'])));
    }
    if (mounted) {
      setState(() {
        messages = messageContainers;
        user = rsp;
      });
    }
  }

  void _addMessage(String content, bool isMine, DateTime date) {
    messages
        .add(MessageContainer(message: content, isMine: isMine, date: date));
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initializeSocket() async {
    Map<String, dynamic> rsp = await ApiService().getUserProfile();
    // Configura la conexión con el servidor Socket.IO
    socket = IO.io(
      'http://3.135.121.50:4000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    socket.on("newMessage", (message) {
      if (!mounted) return;
      print("Nuevo mensaje: $message");
      if (message['_id_sender'] == user['user']['_id_user']) {
        _addMessage(message['content'], true, DateTime.now());
      } else {
        _addMessage(message['content'], false, DateTime.now());
      }
    });

    // Configura los listeners para manejar eventos

    socket.on('joinConversation', (_) {
      print("Uniendose a conexion");
    });

    socket.on("error", (err) {
      print("Error mensaje:" + err);
    });

    socket.on("connect_error", (err) {
      print("Error de conexión: $err");
    });

    socket.on('authentication_error', (data) {
      print('Error de autenticación: $data');
    });

    socket.on('connect', (_) {
      print('Conectado al servidor');
      print(socket.connected);
    });

    socket.on("disconnect", (_) {
      print("Desconectado del servidor");
    });

    socket.on("userTyping", (_) {
      print("Escribiendo");
    });

    // Inicia la conexión
    socket.connect();
    socket.emit('joinConversation',
        {'_id_sender': rsp['user']['_id_user'], '_id_receiver': receiver});
  }

  @override
  void initState() {
    super.initState();
    loadMessages();
    initializeSocket();
  }

  @override
  void dispose() {
    socket.off("newMessage");
    socket.off("joinConversation");
    socket.off("error");
    socket.off("connect_error");
    socket.off("authentication_error");
    socket.off("connect");
    socket.off("disconnect");
    socket.off("userTyping");
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat nombre usuario',
          style: TextStyle(
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(children: [
          Flexible(
            child: ListView.builder(
              reverse: true,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                return Container(
                  child: Column(children: [
                    messages[messages.length - 1 - index],
                    SizedBox(height: 5.0)
                  ]),
                );
              },
              itemCount: messages.length,
            ),
          ),
          Container(
            width: double.maxFinite,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              // border: Border(
              //   top: BorderSide(
              //     color: Colors.grey[200]!,
              //     width: 1,
              //   ),
              // ),
            ),
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(56)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: CircleAvatar(
                      radius: 18,
                      child: Text("HA",
                          style: TextStyle(color: Colors.deepOrangeAccent)),
                      backgroundColor: const Color.fromARGB(255, 254, 223, 214),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: TextField(
                        controller: _textFieldController,
                        onChanged: (content) => msg = content,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message...',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      socket.emit('sendMessage', {
                        'content': msg,
                        '_id_sender': user['user']['_id_user'],
                        '_id_receiver': receiver
                      });
                      _textFieldController.clear();
                    },
                    icon: Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
