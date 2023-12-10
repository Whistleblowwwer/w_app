import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:socket_io_common/src/util/event_emitter.dart';
import 'package:w_app/screens/chat/widgets/message_cont.dart';
import 'package:w_app/services/api/api_service.dart';

class InboxScreen extends StatefulWidget{
  String receiver;
  String token;

  InboxScreen({required this.receiver, required this.token});

  
  @override
  State<InboxScreen> createState() => _InboxScreenState(receiver,token);
}

class _InboxScreenState extends State<InboxScreen>{
  TextEditingController _textFieldController = TextEditingController();
  List<MessageContainer> messages = [];
  String msg ="";
  late IO.Socket socket;
  String token;
  String receiver;
  Map<String, dynamic> user= {};


  _InboxScreenState(this.receiver,this.token);

  Future<void> loadMessages() async{
    List<dynamic> msg = await ApiService().getConversationMessages(receiver);
    Map<String, dynamic> rsp = await ApiService().getUserProfile();
    List<MessageContainer> messageContainers=[];
    for(int i=msg.length-1;i>=0;i--){
      bool mine=false;
      if(msg[i]['Sender']['_id_user']==rsp['user']['_id_user']){
        mine=true;
      }
      messageContainers.add(MessageContainer(message: msg[i]['content'], isMine:mine, date: DateTime.parse(msg[i]['createdAt'])));
    }
    setState(() {
        messages = messageContainers;
        user = rsp;
      });
  }

  void _addMessage(String content, bool isMine, DateTime date){
    messages.add(MessageContainer(message: content, isMine: isMine, date: date));
    setState(() {});
  }

  Future<void> initializeSocket() async {
    Map<String, dynamic> rsp = await ApiService().getUserProfile();
    // Configura la conexión con el servidor Socket.IO
    socket = IO.io(
      'http://192.168.1.15:4000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token})
        .build(),
    );

    socket.on("newMessage", (message) {
      print("Nuevo mensaje: $message");
      if(message['_id_sender']==user['user']['_id_user']){
        _addMessage(message['content'], true, DateTime.now());
      }else{
        _addMessage(message['content'], false, DateTime.now());
      }
    });

    // Configura los listeners para manejar eventos

    socket.on('joinConversation', (_){
      print("Uniendose a conexion");
    });

    socket.on("error", (err) {
      print("Error mensaje:"+ err);
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
    socket.emit('joinConversation',{
      '_id_sender': rsp['user']['_id_user'],
      '_id_receiver':receiver
    });
  }

  @override
  void initState() {
    super.initState();
    loadMessages();
    initializeSocket();
  }

  @override
  void dispose() {
    // Cierra la conexión cuando sale
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
        title: Text('Chat'),
        centerTitle: true,
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                reverse: true,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(16.0),
                itemBuilder: (context, index) {
                  return Container(
                    child: Column(
                      children: [
                        messages[messages.length-1-index],
                        SizedBox(height: 5.0)
                      ]),
                  );
                },
                itemCount: messages.length,
              ),
            ),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: TextField(
                        controller: _textFieldController,
                        onChanged: (content) => msg=content,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your message here...',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      print('Sending message...');
                      socket.emit('sendMessage',
                      {
                        'content': msg,
                        '_id_sender': user['user']['_id_user'],
                        '_id_receiver':receiver
                      });
                      _textFieldController.clear();
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}