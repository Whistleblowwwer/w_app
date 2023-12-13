import 'package:flutter/material.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/chat/widgets/chat_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final User user;
  ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  _ChatPageState();

  dynamic conversations = [];
  late IO.Socket socket;

  //   late SocketBloc _socketBloc;

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  void initState() {
    // _socketBloc = BlocProvider.of<SocketBloc>(context);
    //     _socketBloc.add(Connect()); // Conectar usando SocketBloc
    initializeSocket();
    loadChats();

    super.initState();
  }

  Future<void> initializeSocket() async {
    String? tk = await UserRepository().getToken();
    if (tk != null) {
      socket = IO.io(
        'http://3.135.121.50:4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': tk})
            .build(),
      );
    } else {
      print("Token no provisto o no valido");
    }

    // Configura los listeners para manejar eventos

    socket.on('updateConversations', (_) {
      print("Actualizando chats");
      loadChats();
    });

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
                      //String n=conversations[index]['Sender']['name'];
                      //String ln=conversations[index]['Sender']['last_name'];
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
                              "${conversations[index]['Receiver']['_id_user']}",
                          socket: socket,
                          initials:
                              "${conversations[index]['Sender']['name'][0]}${conversations[index]['Sender']['last_name'][0]}");
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
                              "${conversations[index]['Sender']['_id_user']}",
                          socket: socket,
                          initials:
                              "${conversations[index]['Receiver']['name'][0]}${conversations[index]['Receiver']['last_name'][0]}");
                    }
                  },
                  itemCount: conversations.length,
                ),
              )
            ])));
  }
}
