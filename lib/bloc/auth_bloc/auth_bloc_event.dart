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
  final String name;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  final DateTime birthdate;
  final String gender;
  final String role;

  // ... (otros parámetros necesarios para crear un usuario)

  CreateUser({
    required this.name,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    required this.birthdate,
    required this.gender,
    required this.role,
  });

  @override
  // TODO: implement props
  List<Object> get props => [
        name,
        lastName,
        phone,
        email,
        password,
        birthdate,
        gender,
        role,
      ];
}
