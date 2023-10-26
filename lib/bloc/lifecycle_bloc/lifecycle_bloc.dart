// app_lifecycle_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';

enum AppLifecycleEvent { resumed }

class AppLifecycleBloc extends Bloc<AppLifecycleEvent, void> {
  final AuthBloc authBloc;

  AppLifecycleBloc(this.authBloc) : super(null) {
    on<AppLifecycleEvent>((event, emit) {
      if (event == AppLifecycleEvent.resumed) {
        authBloc.add(AppResumed());
      }
    });
  }
}
