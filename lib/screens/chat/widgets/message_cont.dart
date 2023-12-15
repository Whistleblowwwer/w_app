import 'package:flutter/material.dart';
import 'package:w_app/bloc/socket_bloc/socket_event.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/styles/gradient_style.dart';

class MessageContainer extends StatelessWidget {
  final Message message;
  final bool isMine;
  final bool showSender;
  final String name;

  MessageContainer(
      {required this.message,
      required this.isMine,
      required this.showSender,
      required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // if (showSender)
        //   Padding(
        //     padding: EdgeInsets.only(
        //       bottom: 4,
        //       top: 0,
        //       left: isMine ? 0 : 0,
        //       right: isMine ? 0 : 0,
        //     ),
        //     child: Row(
        //       mainAxisAlignment:
        //           isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        //       children: [
        //         if (!isMine)
        //           Text(
        //             name,
        //             style: TextStyle(
        //               fontSize: 14,
        //               fontWeight: FontWeight.bold,
        //               color: Colors.grey[900],
        //               fontFamily: 'Montserrat',
        //             ),
        //           ),
        //         if (isMine)
        //           Text(
        //             ' Me',
        //             style: TextStyle(
        //               fontSize: 14,
        //               fontWeight: FontWeight.bold,
        //               color: Colors.grey[900],
        //             ),
        //           ),
        //       ],
        //     ),
        //   ),
        Container(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
                top: showSender ? 4 : 0,
                bottom: isMine ? 0 : 1,
                left: isMine ? 40 : 0,
                right: isMine ? 0 : 40),
            constraints: BoxConstraints(minWidth: 96),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: isMine
                      ? const Radius.circular(0)
                      : const Radius.circular(16),
                  topLeft: isMine
                      ? const Radius.circular(16)
                      : const Radius.circular(0),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                color: isMine ? ColorStyle.solidBlue : Colors.white,
                gradient: isMine ? GradientStyle().twoGradient : null),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${message.content}               ',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Montserrat',
                      color: isMine ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Text(
                        '${message.getFormattedTime()}  ',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          color: isMine
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey[600],
                        ),
                      ),
                      if (isMine)
                        Icon(Icons.done_all_rounded,
                            size: 16, color: Colors.white.withOpacity(0.6)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Text(
        //     message.getFormattedTime(),
        //     style: TextStyle(
        //       fontSize: 12.0,
        //       fontFamily: 'Montserrat',
        //       color: isMine ? Colors.white : Colors.black,
        //     ),
        //     textAlign: TextAlign.end,
        //   ),
        // ),
      ],
    );
  }
}



  // @override
  // Widget build(BuildContext context) {
  //   return Padding(
  //     padding: EdgeInsets.only(
  //         left: isMe ? 64 : 16,
  //         right: 16,
  //         top: isMe ? 2 : 0,
  //         bottom: isMe ? 2 : 0),
  //     child: Stack(
  //       children: [
  //         SizedBox(
  //           width: double.maxFinite,
  //           child: Column(
  //             crossAxisAlignment:
  //                 isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
  //             mainAxisAlignment:
  //                 isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
  //             children: [
  //               if (showSender && isMe)
  //                 Padding(
  //                   padding: const EdgeInsets.only(bottom: 4, top: 8),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       Text(
  //                         '19:24 AM   ',
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           color: Colors.grey[600],
  //                         ),
  //                       ),
  //                       Text(
  //                         message.sender,
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey[900],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               if (showSender && !isMe)
  //                 Padding(
  //                   padding:
  //                       const EdgeInsets.only(left: 48, bottom: 4, top: 16),
  //                   child: Row(
  //                     children: [
  //                       Text(
  //                         message.sender,
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey[900],
  //                         ),
  //                       ),
  //                       Text(
  //                         ' 19:24 AM',
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           color: Colors.grey[600],
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               message.typeMessage == "options"
  //                   ? Container(
  //                       margin: EdgeInsets.only(bottom: 8, left: isMe ? 0 : 48),
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 16, vertical: 0),
  //                       decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.only(
  //                             topRight: isMe
  //                                 ? const Radius.circular(0)
  //                                 : const Radius.circular(12),
  //                             topLeft: isMe
  //                                 ? const Radius.circular(12)
  //                                 : const Radius.circular(0),
  //                             bottomLeft: const Radius.circular(12),
  //                             bottomRight: const Radius.circular(12),
  //                           ),
  //                           color:
  //                               isMe ? const Color(0xFFFF6E40) : Colors.white,
  //                           gradient:
  //                               isMe ? GradientStyle().fourGradient : null),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Padding(
  //                             padding:
  //                                 const EdgeInsets.only(top: 16, bottom: 8),
  //                             child: Text(
  //                               message.text,
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 color: isMe ? Colors.white : Colors.black,
  //                               ),
  //                             ),
  //                           ),
  //                           Container(
  //                             margin: EdgeInsets.only(top: 16, bottom: 8),
  //                             width: 228,
  //                             child: Column(
  //                               children: List.generate(
  //                                 message.options!
  //                                     .length, // Número de repeticiones
  //                                 (int index) {
  //                                   return GestureDetector(
  //                                     onTap: () {
  //                                       if (onTapOptions != null) {
  //                                         onTapOptions!(index);
  //                                       }
  //                                     },
  //                                     child: Container(
  //                                       alignment: Alignment.center,
  //                                       margin:
  //                                           const EdgeInsets.only(bottom: 8),
  //                                       padding: const EdgeInsets.symmetric(
  //                                           vertical: 14, horizontal: 24),
  //                                       decoration: BoxDecoration(
  //                                         border: Border.all(
  //                                           color: isMe
  //                                               ? Colors.white
  //                                               : Color(0xFF616161),
  //                                         ),
  //                                         borderRadius:
  //                                             BorderRadius.circular(8),
  //                                       ),
  //                                       child: Text(
  //                                         message.options![index],
  //                                         style: TextStyle(
  //                                           color: isMe
  //                                               ? Colors.white
  //                                               : Colors.black,
  //                                           fontWeight: FontWeight.bold,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   : message.typeMessage == "load"
  //                       ? Container(
  //                           alignment: Alignment.center,
  //                           margin:
  //                               EdgeInsets.only(bottom: 8, left: isMe ? 0 : 48),
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: 16, vertical: 0),
  //                           width: 102,
  //                           decoration: BoxDecoration(
  //                             color: Colors.white,
  //                             borderRadius: BorderRadius.only(
  //                               topRight: Radius.circular(16),
  //                               topLeft: Radius.circular(0),
  //                               bottomLeft: Radius.circular(16),
  //                               bottomRight: Radius.circular(16),
  //                             ),
  //                           ),
  //                           child: LoadingDotsAnimation())
  //                       : Container(
  //                           margin: EdgeInsets.only(
  //                               bottom: isMe ? 0 : 8, left: isMe ? 0 : 48),
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: 16, vertical: 8),
  //                           decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.only(
  //                                 topRight: isMe
  //                                     ? const Radius.circular(0)
  //                                     : const Radius.circular(16),
  //                                 topLeft: isMe
  //                                     ? const Radius.circular(16)
  //                                     : const Radius.circular(0),
  //                                 bottomLeft: const Radius.circular(16),
  //                                 bottomRight: const Radius.circular(16),
  //                               ),
  //                               color: isMe
  //                                   ? const Color(0xFFFF6E40)
  //                                   : Colors.white,
  //                               gradient:
  //                                   isMe ? GradientStyle().fourGradient : null),
  //                           child: Text(
  //                             message.text,
  //                             style: TextStyle(
  //                               fontSize: 16,
  //                               color: isMe ? Colors.white : Colors.black,
  //                             ),
  //                           ),
  //                         ),
  //             ],
  //           ),
  //         ),
  //         if (showSender && !isMe)
  //           Positioned(
  //             bottom: 0,
  //             child: Container(
  //               width: 40,
  //               height: 40,
  //               padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
  //               decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   gradient: GradientStyle().normalGradient),
  //               child: Image.asset(
  //                 "assets/images/AI.png",
  //                 width: double.maxFinite,
  //                 height: double.maxFinite,
  //                 fit: BoxFit.cover,
  //                 alignment: Alignment.bottomCenter,
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }