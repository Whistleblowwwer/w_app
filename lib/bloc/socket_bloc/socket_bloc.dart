import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_app/bloc/socket_bloc/socket_event.dart';
import 'package:w_app/bloc/socket_bloc/socket_state.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  late IO.Socket _socket;

  SocketBloc() : super(Initial()) {
    on<Connect>(_onConnect);
    on<Disconnect>(_onDisconnect);
    on<SendMessage>(_onSendMessage);
    on<JoinConversation>(_onJoinConversation);
    on<LeaveConversation>(_onLeaveConversation);
    on<NewMessage>(_newMessage);

    // Agrega manejadores para otros eventos según sea necesario
  }

  void _newMessage(NewMessage event, Emitter<SocketState> emit) {
    //emit(ArrivedMessage(event.message));
  }

  FutureOr<void> _onConnect(Connect event, Emitter<SocketState> emit) async {
    String? tk = await UserRepository().getToken();
    if (tk != null) {
      _socket = IO.io(
          'https://api.whistleblowwer.net',
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              //.setAuth({'token': tk})
              .build());
      _socket.auth = {'token': tk};
    }
    /*_socket.on("newMessage", (message) {
      print("Nuevo mensaje: $message");
      if(message['_id_sender']==user['user']['_id_user']){
        _addMessage(message['content'], true, DateTime.now());
      }else{
        _addMessage(message['content'], false, DateTime.now());
      }
    });*/

    // Configura otros listeners aquí...
    _socket.on('sendMessage', (_) {
      print("Enviando Mensaje");
    });

    _socket.on('newMessage', (msg) {
      print("Nuevo Mensaje");
    });

    _socket.on('updateConversations', (_) {
      print("Actualizando chats");
    });

    _socket.on('joinConversation', (_) {
      print("Uniendose a conexion");
    });

    _socket.on('leaveConversation', (_) {
      print("Saliendo de sala");
    });

    _socket.on("error", (err) {
      print("Error mensaje:" + err);
    });

    _socket.on("connect_error", (err) {
      print("Error de conexión: $err");
    });

    _socket.on('authentication_error', (data) {
      print('Error de autenticación: $data');
    });

    _socket.on('connect', (_) {
      print('Conectado al servidor');
      print(_socket.connected);
    });

    _socket.on("disconnect", (_) {
      print("Desconectado del servidor");
    });

    _socket.on("userTyping", (_) {
      print("Escribiendo");
    });

    _socket.connect();

    emit(Connected(_socket));
  }

  FutureOr<void> _onDisconnect(Disconnect event, Emitter<SocketState> emit) {
    print("Desconectando del socket");
    _socket.disconnect();
    emit(Disconnected());
  }

  FutureOr<void> _onSendMessage(SendMessage event, Emitter<SocketState> emit) {
    _socket.emit('sendMessage', {
      'content': event.content,
      '_id_sender': event.idSender,
      '_id_receiver': event.idReceiver
    });
  }

  FutureOr<void> _onJoinConversation(
      JoinConversation event, Emitter<SocketState> emit) {
    _socket.emit('joinConversation',
        {'_id_sender': event.idSender, '_id_receiver': event.idReceiver});
  }

  FutureOr<void> _onLeaveConversation(
      LeaveConversation event, Emitter<SocketState> emit) {
    _socket.emit('leaveConversation',
        {'_id_sender': event.idSender, '_id_receiver': event.idReceiver});
  }

  // Implementa otros manejadores de eventos aquí...

  @override
  Future<void> close() {
    _socket.dispose();
    return super.close();
  }
}
