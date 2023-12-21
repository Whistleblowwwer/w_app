import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:socket_io_common/src/util/event_emitter.dart';
import 'package:w_app/bloc/socket_bloc/socket_bloc.dart';
import 'package:w_app/bloc/socket_bloc/socket_event.dart';
import 'package:w_app/bloc/socket_bloc/socket_state.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/chat/widgets/message_cont.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/glassmorphism.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class InboxScreen extends StatefulWidget {
  final String receiver;
  final String receiverName;
  final String initials;

  InboxScreen(
      {required this.receiver,
      required this.receiverName,
      required this.initials});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // final _keyboardVisibilityController = KeyboardVisibilityController();
  TextEditingController _textFieldController = TextEditingController();
  FocusNode focusNodeTextField = FocusNode();

  List<MessageContainer> messages = [];
  String msg = "";

  late User user;
  late UserBloc _userBloc;
  late SocketBloc _socketBloc;

  @override
  void initState() {
    super.initState();
    _userBloc = BlocProvider.of<UserBloc>(context);
    final stateUser = _userBloc.state;
    if (stateUser is UserLoaded) {
      user = stateUser.user;
    }

    loadMessages();
    _socketBloc = BlocProvider.of<SocketBloc>(context);
    _joinConversation();
    //Usa el socket para manejar los mensajes nuevos
    final state = _socketBloc.state;
    if (state is Connected) {
      state.socket.on('newMessage', (msg) {
        final message = Message.fromJson(msg);
        print("Por mandar add message");
        print(messages);
        _addMessage(message);
      });
    }
  }

  Future<void> loadMessages() async {
    List<dynamic> msg =
        await ApiService().getConversationMessages(widget.receiver);
    print(msg);

    List<MessageContainer> messageContainers = [];
    for (int i = msg.length - 1; i >= 0; i--) {
      final message = Message.fromJson(msg[i]);
      bool isMine = message.idSender == user.idUser;

      // Comprobar si el mensaje anterior tiene un remitente diferente (o si es el primer mensaje)
      bool showSender = i == msg.length - 1 ||
          msg[i]['_id_sender'] != msg[i + 1]['_id_sender'];

      bool showDate = i == msg.length - 1 ||
          !(DateTime.parse(msg[i]['createdAt']).year == DateTime.parse(msg[i+1]['createdAt']).year && 
            DateTime.parse(msg[i]['createdAt']).month == DateTime.parse(msg[i+1]['createdAt']).month &&
            DateTime.parse(msg[i]['createdAt']).day == DateTime.parse(msg[i+1]['createdAt']).day);

      messageContainers.add(MessageContainer(
        message: message,
        isMine: isMine,
        showSender: showSender,
        name: isMine ? 'Me' : widget.receiverName,
        showDate: showDate,
      ));
    }

    if (mounted) {
      setState(() {
        messages = messageContainers;
      });
    }
  }

  void _addMessage(Message message) {
    bool showDate = messages.isEmpty? true :  !(message.createdAt.year == messages.last.message.createdAt.year && 
                                                message.createdAt.month == messages.last.message.createdAt.month &&
                                                message.createdAt.day == messages.last.message.createdAt.day);
    messages.add(MessageContainer(
      message: message,
      isMine: message.idSender == user.idUser,
      showSender: messages.isEmpty
          ? true
          : messages.last.message.idSender != message.idSender,
      name: message.idSender == user.idUser ? 'Me' : widget.receiverName,
      showDate: showDate,
    ));
    print(messages);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _joinConversation() async {
    _socketBloc.add(JoinConversation(user.idUser, widget.receiver));
  }

  @override
  void dispose() {
    _socketBloc.add(LeaveConversation(user.idUser, widget.receiver));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocketBloc, SocketState>(
      listener: (context, state) {},
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Column(children: [
                Flexible(
                  child: ListView.builder(
                    reverse: true,
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 128, bottom: 16),
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
                  height: focusNodeTextField.hasFocus ? 64 : 88,
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
                    margin: EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 8,
                        bottom: focusNodeTextField.hasFocus ? 8 : 32),
                    padding: EdgeInsets.only(right: 8),
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
                            child: Text(widget.initials.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    fontFamily: 'Montserrat')),
                            backgroundColor: ColorStyle.solidBlue,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: TextField(
                              controller: _textFieldController,
                              focusNode: focusNodeTextField,
                              onChanged: (content) => msg = content,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type a message...',
                              ),
                            ),
                          ),
                        ),
                        PressTransform(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _socketBloc.add(
                                SendMessage(msg, user.idUser, widget.receiver));
                            _textFieldController.clear();
                          },
                          child: Icon(
                            Icons.send,
                            color: ColorStyle.solidBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            //AppBarChat
            Positioned(
              top: 0,
              child: GlassMorphism(
                blur: 10,
                opacity: 0.7,
                borderRadius: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 104,
                  padding: EdgeInsets.only(top: 32),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Positioned(
                        left: 42,
                        right: 0,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 104,
                          child: Row(
                            children: [
                              CircularAvatarW(
                                  externalRadius: Offset(42, 42),
                                  internalRadius: Offset(38, 38),
                                  nameAvatar:
                                      widget.receiverName.substring(0, 1),
                                  isCompany: false),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.receiverName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.grey[900],
                                          fontFamily: 'Montserrat',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    "Offline",
                                    style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 26,
                                color: Colors.grey[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        child: Row(
                          children: [
                            // GestureDetector(
                            //   onTap: () {},
                            //   child: Icon(
                            //     Icons.info_outline_rounded,
                            //     size: 26,
                            //     color: Colors.grey[800],
                            //   ),
                            // ),
                            // SizedBox(
                            //   width: sizeH * 2.4,
                            // ),
                            GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.more_vert,
                                size: 26,
                                color: Colors.grey[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
