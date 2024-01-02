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

class CreateUser extends AuthBlocEvent {
  final String userName;
  final String name;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  final DateTime birthdate;
  final String gender;

  // ... (otros parámetros necesarios para crear un usuario)

  CreateUser({
    required this.userName,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    required this.birthdate,
    required this.gender,
  });

  @override
  List<Object> get props => [
        userName,
        name,
        lastName,
        phone,
        email,
        password,
        birthdate,
        gender,
      ];
}
