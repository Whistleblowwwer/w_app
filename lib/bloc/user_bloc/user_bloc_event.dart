import 'package:equatable/equatable.dart';

// User Events
abstract class UserBlocEvent extends Equatable {}

class FetchUserProfile extends UserBlocEvent {
  FetchUserProfile();

  @override
  List<Object> get props => [];
}
