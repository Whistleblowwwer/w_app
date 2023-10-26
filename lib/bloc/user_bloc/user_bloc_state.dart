import 'package:equatable/equatable.dart';
import 'package:w_app/models/user.dart';

// User States
abstract class UserState extends Equatable {}

class UserLoading extends UserState {
  @override
  List<Object> get props => [];
}

class UserLoaded extends UserState {
  final User user;

  UserLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String error;

  UserError(this.error);

  @override
  List<Object> get props => [error];
}

class UserTokenError extends UserState {
  final String error;

  UserTokenError(this.error);
  @override
  List<Object> get props => [error];
}
