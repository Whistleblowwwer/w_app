// Inbox_event.dart

import 'package:equatable/equatable.dart';
import 'package:w_app/bloc/inbox_bloc/inbox_bloc.dart';

abstract class InboxEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadConversations extends InboxEvent {}

class NewMessageReceived extends InboxEvent {
  final MessageModel message;

  NewMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class InboxErrorOccurred extends InboxEvent {
  final String errorMessage;

  InboxErrorOccurred(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
