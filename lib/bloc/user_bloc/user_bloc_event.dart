import 'package:equatable/equatable.dart';

// User Events
abstract class UserBlocEvent extends Equatable {}

class FetchUserProfile extends UserBlocEvent {
  final String token;
  final String idUser;

  FetchUserProfile(this.token, this.idUser);

  @override
  List<Object> get props => [token, idUser];
}
