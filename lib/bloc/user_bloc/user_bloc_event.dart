import 'package:equatable/equatable.dart';
import 'package:w_app/models/user.dart';

// User Events
abstract class UserBlocEvent extends Equatable {}

class FetchUserProfile extends UserBlocEvent {
  FetchUserProfile();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends UserBlocEvent {
  LoadUserProfile();

  @override
  List<Object> get props => [];
}

class UpdateUserProfile extends UserBlocEvent {
  final User user;
  final String? email;
  final String? phone;
  final String? name;
  final String? lastName;
  final String? userName;

  UpdateUserProfile(
      {required this.user,
      this.email,
      this.phone,
      this.name,
      this.lastName,
      this.userName});

  @override
  List<Object?> get props => [user, email, phone, name, lastName, userName];
}
