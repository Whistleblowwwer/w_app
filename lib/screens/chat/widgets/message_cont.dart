import 'package:flutter/material.dart';

class MessageContainer extends StatelessWidget {
  
  final String message;
  final bool isMine;
  final DateTime date; //Cambiable a hora


  MessageContainer({
    required this.message,
    required this.isMine,
    required this.date
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isMine ? Colors.blue : Color.fromARGB(255, 174, 207, 235),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 16.0,
              color: isMine ? Colors.white : Colors.black,
            ),
          ),
          Text(
            date.toString().substring(11, 16),
            style: TextStyle(
              fontSize: 12.0,
              color: isMine ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    ),
    );
  }

}