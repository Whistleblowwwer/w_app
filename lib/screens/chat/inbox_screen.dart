import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:socket_io_common/src/util/event_emitter.dart';
import 'package:w_app/bloc/socket_bloc/socket_bloc.dart';
import 'package:w_app/bloc/socket_bloc/socket_event.dart';
import 'package:w_app/bloc/socket_bloc/socket_state.dart';
import 'package:w_app/screens/chat/widgets/message_cont.dart';
import 'package:w_app/services/api/api_service.dart';

class InboxScreen extends StatefulWidget {
  final String receiver;
  final String receiverName;
  final String initials;

  InboxScreen(
      {required this.receiver,
      required this.receiverName,
      required this.initials});

  @override
  State<InboxScreen> createState() =>
      _InboxScreenState(receiver, receiverName, initials);
}

class _InboxScreenState extends State<InboxScreen> {
  // final _keyboardVisibilityController = KeyboardVisibilityController();
  TextEditingController _textFieldController = TextEditingController();

  List<MessageContainer> messages = [];
  String msg = "";
  String receiver;
  String receiverName;
  String initials;
  Map<String, dynamic> user = {};
  late SocketBloc _socketBloc;

  _InboxScreenState(
      this.receiver, this.receiverName, this.initials);

  Future<void> loadMessages() async {
    List<dynamic> msg = await ApiService().getConversationMessages(receiver);
    print(msg);
    Map<String, dynamic> rsp = await ApiService().getUserProfile();
    List<MessageContainer> messageContainers = [];
    for (int i = msg.length - 1; i >= 0; i--) {
      final message = Message.fromJson(msg[i]);
      messageContainers.add(MessageContainer(
          message: message,
          isMine: message.idSender==user['user']['_id_user']
      ));    
    }
    if (mounted) {
      setState(() {
        messages = messageContainers;
        user = rsp;
      });
    }
  }

  void _addMessage(Message message) {
    messages
        .add(MessageContainer(message: message, isMine: message.idSender==user['user']['_id_user']));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    loadMessages();
    _socketBloc = BlocProvider.of<SocketBloc>(context);
    _joinConversation();
    //Usa el socket para manejar los mensajes nuevos
    final state = _socketBloc.state;
    if(state is Connected){
      state.socket.on('newMessage',(msg) {
        final message = Message.fromJson(msg);
        _addMessage(message);
      });
    }
  }

  Future<void> _joinConversation() async{
    Map<String, dynamic> rsp = await ApiService().getUserProfile();
    _socketBloc.add(JoinConversation(rsp['user']['_id_user'], receiver));
  }

  
  @override
  void dispose() {
    _socketBloc.add(LeaveConversation(user['user']['_id_user'], receiver));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocketBloc,SocketState>(
      listener: (context, state) {
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            receiverName,
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
                        child: Text(initials.toUpperCase(),
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
                        _socketBloc.add(SendMessage(msg, user['user']['_id_user'], receiver));
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
      ),
    );
  }
}
