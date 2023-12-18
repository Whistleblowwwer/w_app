import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/chat/widgets/user_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';

class NewChatPage extends StatefulWidget {
  NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  List<dynamic> users = [];
  late UserBloc _userBloc;
  late User user;

  @override
  void initState() {
    _userBloc = BlocProvider.of<UserBloc>(context);
    final stateUser = _userBloc.state;
    if(stateUser is UserLoaded){
      user=stateUser.user;
    }
    loadUsers();
    super.initState();
  }

  Future<void> loadUsers() async {
    final us = await ApiService().getNewChats();
    if (!mounted) return;
    setState(() {
      users=us;
    });
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
              padding: EdgeInsets.only(top: 88),
              child: RefreshIndicator.adaptive(
                color: ColorStyle.darkPurple,
                onRefresh: () async {
                  await loadUsers();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 40,
                        width: double.maxFinite,
                        margin: EdgeInsets.only(
                            left: 16, right: 16, bottom: 8, top: 8),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        child: TextField(
                          //controller: controllerSearch,
                          maxLines: 1,
                          //focusNode: focusNodeSearch,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Buscar',
                            hintStyle: TextStyle(
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
                            prefixIcon: Icon(FeatherIcons.search,
                                size: 18, color: ColorStyle.textGrey),
                            /*suffixIcon: controllerSearch.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      controllerSearch.clear();
                                    },
                                    icon: Icon(Icons.clear,
                                        size: 20, color: ColorStyle.textGrey),
                                  )
                                : null,*/
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return UserChatCard(
                          name: users[index]['name'],
                          lastName: users[index]['last_name'],
                          receiver: users[index]['_id_user'],
                          photoUrl: users[index]['profile_picture_url'],
                          initials: user.name[0]+user.lastName[0],
                          username: users[index]['nick_name']);
                      },
                    )
                  ],
                ),
              )),
          Container(
            width: double.maxFinite,
            height: 88,
            color: Colors.white,
            padding: EdgeInsets.only(top: 40),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 8),
                        child: Icon(FeatherIcons.arrowLeft),
                      ),
                      Text(
                        "Atrás",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Nuevo Chat",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ));
  }

}