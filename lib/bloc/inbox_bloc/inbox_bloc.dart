import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_app/bloc/inbox_bloc/inbox_event.dart';
import 'package:w_app/bloc/inbox_bloc/inbox_state.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:intl/intl.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  InboxBloc() : super(InboxInitial()) {
    on<LoadConversations>((event, emit) async {
      emit(InboxLoading());
      try {
        List<dynamic> jsonList = await ApiService().getChats();

        List<ConversationModel> conversations = jsonList
            .map((jsonItem) => ConversationModel.fromJson(jsonItem))
            .toList();
        emit(InboxLoaded(conversations));
      } catch (e) {
        emit(InboxError(e.toString()));
      }
    });

    on<NewMessageReceived>((event, emit) {
      if (state is InboxLoaded) {
        final currentState = state as InboxLoaded;
        // Aquí debes encontrar la conversación correspondiente y actualizarla con el nuevo mensaje
        // Luego emitir el estado actualizado
      }
    });

    on<InboxErrorOccurred>((event, emit) {
      emit(InboxError(event.errorMessage));
    });
  }
}

// message_model.dart

class MessageModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final bool isValid;

  MessageModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.isValid,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final date = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.parse(json['createdAt']).toLocal());
    print('-----');
    print(date);
    return MessageModel(
      id: json['_id_message'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      isValid: json['is_valid'],
    );
  }
}

// conversation_model.dart

class ConversationModel {
  final UserModel receiver;
  final MessageModel lastMessage;

  ConversationModel({
    required this.receiver,
    required this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      receiver: UserModel.fromJson(json['Receiver']),
      lastMessage: MessageModel.fromJson(json['Message']),
    );
  }
}

// user_model.dart

class UserModel {
  final String id;
  final String name;
  final String lastName;
  final String? profilePictureUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    this.profilePictureUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id_user'],
      name: json['name'],
      lastName: json['last_name'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }
}
