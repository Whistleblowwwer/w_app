import 'package:equatable/equatable.dart';
import 'package:w_app/bloc/inbox_bloc/inbox_bloc.dart';

abstract class InboxState extends Equatable {
  @override
  List<Object> get props => [];
}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {}

class InboxLoaded extends InboxState {
  final List<ConversationModel> conversations;

  InboxLoaded(this.conversations);

  @override
  List<Object> get props => [conversations];
}

class InboxError extends InboxState {
  final String errorMessage;

  InboxError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
