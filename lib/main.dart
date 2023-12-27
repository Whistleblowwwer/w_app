import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_state.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/search_bloc/search_bloc.dart';
import 'package:w_app/bloc/socket_bloc/socket_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/screens/signInUp/sign_in_screen.dart';
import 'package:w_app/screens/start_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/snackbar.dart';
import 'repository/user_repository.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final apiService = ApiService();
  final userRepository = UserRepository();

  final AuthBloc authBloc = AuthBloc(
    AuthUnauthenticated(),
    apiService,
    userRepository,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MainApp(authBloc, apiService, userRepository));
  });
}

class MainApp extends StatefulWidget {
  final AuthBloc authBloc;
  final ApiService apiService;
  final UserRepository userRepository;
  // final AppLifecycleBloc appLifecycleBloc;

  const MainApp(this.authBloc, this.apiService, this.userRepository,
      {super.key}); //: appLifecycleBloc = AppLifecycleBloc(authBloc);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          switch (settings.name) {
            case '/':
              return AuthHandler(widget.userRepository);
            case '/SignInPage':
              return const SignInScreen();
            default:
              return Scaffold(
                body: Center(child: Text('Unknown route: ${settings.name}')),
              );
          }
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Agrega el observer
    widget.authBloc.add(AppResumed());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // widget.authBloc.add(AppResumed());
      // widget.appLifecycleBloc.add(AppLifecycleEvent.resumed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => widget.authBloc,
          ),
          BlocProvider<SocketBloc>(
            create: (context) => SocketBloc(),
          ),
          // BlocProvider<AppLifecycleBloc>(
          //   create: (context) => widget.appLifecycleBloc,
          // ),
          BlocProvider<UserBloc>(
            create: (context) => UserBloc(UserLoading(), widget.apiService),
          ),
          BlocProvider<SearchBloc>(create: (context) => SearchBloc()),
          BlocProvider<FeedBloc>(
            create: (context) => FeedBloc(widget.apiService),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color.fromRGBO(28, 79, 200, 1),
            popupMenuTheme: PopupMenuThemeData(
              textStyle: const TextStyle(fontFamily: 'Anuphan'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 0,
              color: const Color.fromRGBO(255, 255, 255, .2),
            ),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
            // ... otras locales que soportes
          ],
          onGenerateRoute: generateRoute, // Usar la función generateRoute
        ));
  }
}

class AuthHandler extends StatelessWidget {
  final UserRepository userRepository;

  const AuthHandler(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          showErrorSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return StartPage(userRepository: userRepository);
        } else if (state is AuthUnauthenticated || state is AuthError) {
          return const SignInScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: ColorStyle.grey, // Fondo del indicador
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorStyle.darkPurple),
              ),
            ),
          );
        }
      },
    );
  }
}

// class NavigationScreen extends StatelessWidget {
//   final Widget screen;

//   NavigationScreen(this.screen);

//   @override
//   Widget build(BuildContext context) {
//     return Navigator(
//       onGenerateRoute: (settings) {
//         return MaterialPageRoute(
//           builder: (context) => screen,
//         );
//       },
//     );
//   }
// }
