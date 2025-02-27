import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_state.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/services/firebase/firebase_api.dart';

class AuthBloc extends Bloc<AuthBlocEvent, AuthState> {
  final ApiService apiService;
  final UserRepository userRepository;

  AuthBloc(AuthState initialState, this.apiService, this.userRepository)
      : super(initialState) {
    on<SignInButtonPressed>(_onSignInButtonPressed);
    on<AppResumed>(_onAppResumed);
    on<LogOutUser>(_logOutUser);
    on<CreateUser>(_onCreateUser);
  }

  FutureOr<void> _onSignInButtonPressed(
      SignInButtonPressed event, Emitter<AuthState> emit) async {
    // emit(AuthLoading());
    emit(AuthUnauthenticated());
    await userRepository.deleteToken();
    try {
      final response =
          await apiService.signIn(event.username.toLowerCase(), event.password);
      print(response);

      if (response.containsKey('token')) {
        await userRepository.saveToken(response['token']);
        await FirebaseApi().initNotifications();

        emit(AuthAuthenticated());
      } else {
        if (response.containsKey('message')) {
          emit(AuthError(response['message']));
        } else {
          emit(AuthError('Sign in failed'));
        }
      }
    } catch (e) {
      if (e == 'Token is invalid or expired.') {
        //Gestion del token
        emit(AuthError(''));
      } else {
        emit(AuthError(e.toString()));
      }
    }
  }

  FutureOr<void> _onAppResumed(
      AppResumed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await userRepository.getToken();
      if (token != null) {
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
      if (e.toString().contains('Token is invalid or expired.')) {
        //Gestion del token
        emit(AuthError(''));
      } else {
        emit(AuthError(e.toString()));
      }
    }
  }

  FutureOr<void> _logOutUser(LogOutUser event, Emitter<AuthState> emit) async {
    await apiService.logOut();
    await userRepository.deleteToken();
    emit(AuthUnauthenticated());
  }

  FutureOr<void> _onCreateUser(
      CreateUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiService.createUser(
        userName: event.userName,
        name: event.name,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email.toLowerCase(),
        password: event.password,
        birthdate: event.birthdate.toString(),
        gender: event.gender,
      );

      if (response.containsKey('token')) {
        await userRepository.saveToken(response['token']);
        emit(AuthAuthenticated());
      } else {
        if (response.containsKey("errors")) {
          emit(AuthError(response["errors"][0]["message"]));
        } else {
          emit(AuthError('Sign in failed'));
        }
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
