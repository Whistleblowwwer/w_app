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
  }

  FutureOr<void> _onFetchUserProfile(
      FetchUserProfile event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      print("aa");
      final response = await apiService.getUserProfile();
      User user = User.fromJson(response['user']);

      emit(UserLoaded(user));
    } catch (e) {
      if (e.toString().contains('Token is invalid or expired')) {
        emit(UserTokenError(e.toString()));
      } else {
        emit(UserError(e.toString()));
      }
    }
  }

  FutureOr<void> _onLoadUserProfile(
      LoadUserProfile event, Emitter<UserState> emit) async {
    // emit(UserLoading());
    try {
      final response = await apiService.getUserProfile();
      User user = User.fromJson(response['user']);

      emit(UserLoaded(user));
    } catch (e) {
      if (e.toString().contains('Token is invalid or expired')) {
        emit(UserTokenError(e.toString()));
      } else {
        emit(UserError(e.toString()));
      }
    }
  }
}
