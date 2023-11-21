import 'package:equatable/equatable.dart';

abstract class FeedSideEffect extends Equatable {
  @override
  List<Object> get props => [];
}

class AddCommentSideEffect extends FeedSideEffect {
  final String message;

  AddCommentSideEffect(this.message);

  @override
  List<Object> get props => [message];
}
