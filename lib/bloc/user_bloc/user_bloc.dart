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
  }

  FutureOr<void> _onFetchUserProfile(
      FetchUserProfile event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      print("aa");
      final response = await apiService.getUserProfile();
      final user = User.fromJson(response['user']);

      emit(UserLoaded(user));
    } catch (e) {
      if (e.toString().contains('Token is invalid or expired')) {
        print("eeee");
        emit(UserTokenError(e.toString()));
      } else {
        emit(UserError(e.toString()));
      }
    }
  }
}
