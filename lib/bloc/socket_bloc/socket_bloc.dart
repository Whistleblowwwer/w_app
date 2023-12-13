import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:w_app/bloc/socket_bloc/socket_event.dart';
import 'package:w_app/bloc/socket_bloc/socket_state.dart';
import 'package:w_app/repository/user_repository.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  late final io.Socket _socket;

  SocketBloc() : super(Initial()) {
    on<Connect>(_onConnect);
    on<Disconnect>(_onDisconnect);
    on<SendMessage>(_onSendMessage);
    on<JoinConversation>(_onJoinConversation);
    on<LeaveConversation>(_onLeaveConversation);
    // Agrega manejadores para otros eventos según sea necesario
  }

  void _onConnect(Connect event, Emitter<SocketState> emit) async {
    String? tk = await UserRepository().getToken();
    if (tk != null) {
      _socket = io.io(
          'http://3.135.121.50:4000',
          io.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .setAuth({'token': tk})
              .build());
    }

    _socket.onConnect((_) => emit(Connected()));
    _socket.onDisconnect((_) => emit(Disconnected()));
    // Configura otros listeners aquí...
    _socket.connect();
  }

  void _onDisconnect(Disconnect event, Emitter<SocketState> emit) {
    _socket.disconnect();
  }

  void _onSendMessage(SendMessage event, Emitter<SocketState> emit) {
    _socket.emit('sendMessage', {
      'content': event.content,
      'idSender': event.idSender,
      'idReceiver': event.idReceiver
    });
  }

  void _onJoinConversation(JoinConversation event, Emitter<SocketState> emit) {
    _socket.emit('joinConversation',
        {'idSender': event.idSender, 'idReceiver': event.idReceiver});
  }

  void _onLeaveConversation(
      LeaveConversation event, Emitter<SocketState> emit) {
    _socket.emit('leaveConversation',
        {'idSender': event.idSender, 'idReceiver': event.idReceiver});
  }

  // Implementa otros manejadores de eventos aquí...

  @override
  Future<void> close() {
    _socket.dispose();
    return super.close();
  }
}
