import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_state.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/services/api/api_service.dart';

class AuthBloc extends Bloc<AuthBlocEvent, AuthState> {
  final ApiService apiService;
  final UserRepository userRepository;

  AuthBloc(AuthState initialState, this.apiService, this.userRepository)
      : super(initialState) {
    on<SignInButtonPressed>(_onSignInButtonPressed);
    on<AppResumed>(_onAppResumed);
    on<LogOutUser>(_logOutUser);
  }

  FutureOr<void> _onSignInButtonPressed(
      SignInButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiService.signIn(event.username, event.password);

      if (response.containsKey('token')) {
        await userRepository.saveToken(response['token']);
        print("r");
        emit(AuthAuthenticated());
      } else {
        print('Sign in failed');
        emit(AuthError('Sign in failed'));
      }
    } catch (e) {
      print(e.toString());
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _onAppResumed(
      AppResumed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await userRepository.getToken();

      //(token != null && apiService.validateToken(token))
      if (token != null) {
        print("hey");
        final validate = await apiService.validateAccesToken(token);

        if (validate) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _logOutUser(LogOutUser event, Emitter<AuthState> emit) async {
    await userRepository.deleteToken();
    emit(AuthUnauthenticated());
  }
}
