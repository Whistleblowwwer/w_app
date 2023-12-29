import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/services/api/api_service.dart';

class UserBloc extends Bloc<UserBlocEvent, UserState> {
  final ApiService apiService;

  UserBloc(UserState initialState, this.apiService) : super(initialState) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  FutureOr<void> _onFetchUserProfile(
      FetchUserProfile event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      print("aa");
      final response = await apiService.getUserProfile();
      User user = User.fromJson(response['user']);

      emit(UserLoaded(user, ""));
    } catch (e) {
      if (e.toString().contains('Token is invalid or expired')) {
        emit(UserTokenError(e.toString()));
      } else {
        emit(UserError(e.toString()));
      }
    }
  }

  FutureOr<void> _onUpdateUserProfile(
      UpdateUserProfile event, Emitter<UserState> emit) async {
    try {
      final response = await apiService.editUser(
          email: event.email,
          userName: event.userName,
          name: event.name,
          lastName: event.lastName,
          phone: event.phone);
      User updateUser = User.fromJson(response['user']);
      emit(UserLoaded(updateUser, ""));
    } catch (e) {
      emit(UserLoaded(event.user, "No se guardaron cambios"));
    }
  }

  FutureOr<void> _onLoadUserProfile(
      LoadUserProfile event, Emitter<UserState> emit) async {
    // emit(UserLoading());
    try {
      final response = await apiService.getUserProfile();
      User user = User.fromJson(response['user']);

      emit(UserLoaded(user, ""));
    } catch (e) {
      if (e.toString().contains('Token is invalid or expired')) {
        emit(UserTokenError(e.toString()));
      } else {
        emit(UserError(e.toString()));
      }
    }
  }
}
