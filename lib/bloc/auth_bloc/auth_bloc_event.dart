import 'package:equatable/equatable.dart';

// Auth Events
abstract class AuthBlocEvent extends Equatable {}

class SignInButtonPressed extends AuthBlocEvent {
  final String username;
  final String password;

  SignInButtonPressed({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class AppResumed extends AuthBlocEvent {
  @override
  List<Object> get props => [];
}

class LogOutUser extends AuthBlocEvent {
  @override
  List<Object> get props => [];
}
