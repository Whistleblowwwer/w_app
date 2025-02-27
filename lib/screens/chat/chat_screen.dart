import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/socket_bloc/socket_bloc.dart';
import 'package:w_app/bloc/socket_bloc/socket_state.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/chat/new_chat_screen.dart';
import 'package:w_app/screens/chat/widgets/chat_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/snackbar.dart';

class ChatPage extends StatefulWidget {
  final User user;
  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  _ChatPageState();

  List<dynamic> conversations = [];
  List<dynamic> listFilter = [];
  TextEditingController controllerSearch = TextEditingController();
  FocusNode focusNodeSearch = FocusNode();
  late SocketBloc _socketBloc;

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
    super.initState();
    loadChats();
    controllerSearch.addListener(_filterChats);

    _socketBloc = BlocProvider.of<SocketBloc>(context);
    final state = _socketBloc.state;
    if (state is Connected) {
      state.socket.on('updateConversations', (_) {
        loadChats();
      });
    }
  }

  // Función para filtrar chats
  void _filterChats() {
    String searchTerm = controllerSearch.text;
    if (searchTerm.isNotEmpty) {
      List<dynamic> filteredList = conversations.where((chat) {
        String name = chat['Sender']['_id_user'] == widget.user.idUser
            ? chat['Receiver']['name'].toLowerCase()
            : chat['Sender']['name'].toLowerCase();
        return name.contains(searchTerm.toLowerCase());
      }).toList();

      setState(() {
        listFilter = filteredList;
      });
    } else {
      setState(() {
        listFilter = conversations;
      });
    }
  }

  Future<void> loadChats() async {
    try {
      final conv = await ApiService().getChats();
      if (!mounted) return;
      setState(() {
        conversations = conv;
        listFilter = [...conv];
      });
    } catch (e) {
      showErrorSnackBar(context, "No se cargaron los chats");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
                width: sizeW * 100,
                height: sizeH * 100,
                padding: const EdgeInsets.only(top: 88),
                child: RefreshIndicator.adaptive(
                  color: ColorStyle.darkPurple,
                  onRefresh: () async {
                    await loadChats();
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          height: 40,
                          width: double.maxFinite,
                          margin: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 8, top: 8),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)),
                          child: TextField(
                            controller: controllerSearch,
                            maxLines: 1,
                            focusNode: focusNodeSearch,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar',
                              hintStyle: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ColorStyle.textGrey),
                              contentPadding: const EdgeInsets.only(),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: ColorStyle.lightGrey,
                              prefixIcon: const Icon(FeatherIcons.search,
                                  size: 18, color: ColorStyle.textGrey),
                              suffixIcon: controllerSearch.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        controllerSearch.clear();
                                      },
                                      icon: const Icon(Icons.clear,
                                          size: 20, color: ColorStyle.textGrey),
                                    )
                                  : null,
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                      SliverList.builder(
                        itemCount: listFilter.length,
                        itemBuilder: (context, index) {
                          if (listFilter[index]['Sender']['_id_user'] ==
                              widget.user.idUser) {
                            return ChatCard(
                              name: "${listFilter[index]['Receiver']['name']}",
                              lastName:
                                  "${listFilter[index]['Receiver']['last_name']}",
                              lastMessage:
                                  "Tú: ${listFilter[index]['Message']['content']}",
                              lastMessageTime:
                                  "${listFilter[index]['Message']['createdAt']}",
                              photoUrl:
                                  "${listFilter[index]['Receiver']['profile_picture_url']}",
                              receiver:
                                  "${listFilter[index]['Receiver']['_id_user']}",
                              initials:
                                  "${listFilter[index]['Sender']['name'][0]}${listFilter[index]['Sender']['last_name'][0]}",
                            );
                          } else {
                            return ChatCard(
                              name: "${listFilter[index]['Sender']['name']}",
                              lastName:
                                  "${listFilter[index]['Sender']['last_name']}",
                              lastMessage:
                                  "${listFilter[index]['Message']['content']}",
                              lastMessageTime:
                                  "${listFilter[index]['Message']['createdAt']}",
                              photoUrl:
                                  "${listFilter[index]['Sender']['profile_picture_url']}",
                              receiver:
                                  "${listFilter[index]['Sender']['_id_user']}",
                              initials:
                                  "${listFilter[index]['Receiver']['name'][0]}${listFilter[index]['Receiver']['last_name'][0]}",
                            );
                          }
                        },
                      )
                    ],
                  ),
                )),
            Container(
              width: double.maxFinite,
              height: 88,
              color: Colors.white,
              padding: const EdgeInsets.only(top: 40),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Icon(FeatherIcons.arrowLeft),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "Mensajes",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  //Aca redirecciona a new chat
                  Positioned(
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                settings: const RouteSettings(),
                                builder: (context) => NewChatPage()));
                      },
                      child: const Icon(
                        FeatherIcons.edit,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}


// class User {
//   final String id;
//   final String name;
//   final String lastName;
//   final String? profilePictureUrl;

//   User({
//     required this.id,
//     required this.name,
//     required this.lastName,
//     this.profilePictureUrl,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['_id_user'],
//       name: json['name'],
//       lastName: json['last_name'],
//       profilePictureUrl: json['profile_picture_url'],
//     );
//   }
// }

// class Message {
//   final String id;
//   final String content;
//   final bool isValid;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final User sender;
//   final User receiver;

//   Message({
//     required this.id,
//     required this.content,
//     required this.isValid,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.sender,
//     required this.receiver,
//   });

//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       id: json['_id_message'],
//       content: json['content'],
//       isValid: json['is_valid'],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//       sender: User.fromJson(json['Sender']),
//       receiver: User.fromJson(json['Receiver']),
//     );
//   }
// }
