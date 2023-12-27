import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/chat/inbox_screen.dart';
import 'package:w_app/widgets/circularAvatar.dart';

class ChatCard extends StatelessWidget {
  final String name;
  final String lastName;
  final String lastMessage;
  final String lastMessageTime;
  final String photoUrl;
  final String receiver;
  final String initials;

  const ChatCard(
      {super.key,
      required this.name,
      required this.lastName,
      required this.lastMessage,
      required this.lastMessageTime,
      required this.photoUrl,
      required this.receiver,
      required this.initials});

  String getDateTimeString() {
    final dateTIme = DateTime.parse(lastMessageTime);
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (dateTIme.year == now.year &&
        dateTIme.month == now.month &&
        dateTIme.day == now.day) {
      //Retorna la hora de ultimo mensaje si es hoy
      return DateTime.parse(lastMessageTime)
          .toLocal()
          .toIso8601String()
          .substring(11, 16);
    } else if (dateTIme.year == yesterday.year &&
        dateTIme.month == yesterday.month &&
        dateTIme.day == yesterday.day) {
      //Retorna la Ayer si fue ayer
      return "Ayer";
    } else {
      //Retorna la fecha en formaro DD/MM/AAAA si fue antes de ayer o mas atras
      return DateFormat('dd/MM/yyyy').format(dateTIme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    return GestureDetector(
      onTap: () async {
        //Obtiene el token
        String? tk = await UserRepository().getToken();
        if (tk != null) {
          //Sacar el token largo, el; corto ya esta
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              settings: const RouteSettings(),
              builder: (context) => InboxScreen(
                  receiver: receiver,
                  receiverName: name + " " + lastName,
                  initials: initials)));
        } else {
          print("Token no provisto o no valido");
        }
      },
      child: Container(
        padding:
            const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
        width: sizeW * 100,
        color: Colors.white,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularAvatarW(
                  externalRadius: const Offset(56, 56),
                  internalRadius: const Offset(48, 48),
                  sizeText: 24,
                  nameAvatar: name.substring(0, 1) + lastName.substring(0, 1),
                  isCompany: false),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name $lastName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      getDateTimeString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
