import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/bloc/socket_bloc/socket_bloc.dart';
import 'package:w_app/bloc/socket_bloc/socket_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/screens/signInUp/widgets/roundedBottomSheet.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/showAdaptiveDialog.dart';
import 'package:w_app/widgets/snackbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserBloc userBloc;
  late AuthBloc authBloc;
  late SocketBloc socketBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userBloc = BlocProvider.of<UserBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    socketBloc = BlocProvider.of<SocketBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;
    // final stateUser = BlocProvider.of<UserBloc>(context).state;

    return Scaffold(
      body: SizedBox(
          width: sizeW * 100,
          height: sizeH * 100,
          child: Stack(
            children: [
              Positioned.fill(
                  top: 96,
                  child: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: List.generate(
                                1,
                                (index) => Padding(
                                      padding: EdgeInsets.only(
                                          top: 16, bottom: 16, left: 16),
                                      child: const Row(
                                        children: [
                                          Icon(FeatherIcons.info),
                                          Text(
                                            "  Información",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Montserrat'),
                                          )
                                        ],
                                      ),
                                    )),
                          ),
                          Container(
                            width: double.maxFinite,
                            height: 0.5,
                            color: ColorStyle.borderGrey,
                            margin: EdgeInsets.only(top: 8, bottom: 8),
                          ),
                          PressTransform(
                            onPressed: () {
                              showAdaptiveDialogIos(
                                  context: context,
                                  title: 'Advertencia',
                                  content: '¿Seguro deseas eliminar tu cuenta?',
                                  onTapCancel: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  onTapOk: () async {
                                    if (await ApiService().deleteUser()) {
                                      authBloc.add(LogOutUser());
                                      socketBloc.add(Disconnect());
                                    } else {
                                      if (mounted) {
                                        showErrorSnackBar(
                                            context, "No se elimino la cuenta");
                                      }
                                    }
                                    if (mounted) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    }
                                  });
                            },
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: 16, bottom: 16, top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Eliminar tus datos y cuenta",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  Text(
                                    "Eliminar tus datos y cuenta",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: ColorStyle.textGrey,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PressTransform(
                              onPressed: () {
                                showAdaptiveDialogIos(
                                    context: context,
                                    title: 'Advertencia',
                                    content: '¿Seguro deseas cerrar sesión?',
                                    onTapCancel: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                    onTapOk: () async {
                                      authBloc.add(LogOutUser());
                                      socketBloc.add(Disconnect());
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      // Navigator.of(context);
                                    });
                              },
                              child: Container(
                                  margin: EdgeInsets.only(
                                      left: 16, right: 16, bottom: 8, top: 8),
                                  height: 48,
                                  width: double.maxFinite,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: ColorStyle.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Text(
                                    "Cerrar Sesión",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ))),
                          Center(
                            child: Text(
                              "Versión 0.1.0",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: ColorStyle.textGrey,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 8, top: 24),
                            child: Text.rich(TextSpan(
                                children: [
                                  const TextSpan(
                                      text:
                                          "D.R.© ANCER 2023, S.A.P.I. DE C.V., México 2023. Utilización del sitio únicamente bajo "),
                                  TextSpan(
                                      text: "Términos legales",
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           PDFScreen()),
                                          // );

                                          final Uri url = Uri.parse(
                                              'https://whistleblowwer.com/t&c');
                                          if (!await launchUrl(url)) {
                                            print('Could not launch $url');
                                          }
                                        },
                                      style: const TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  const TextSpan(
                                      text:
                                          ". Pedro Infante # 1000, Colonia Cumbres Oro Regency, Monterrey, Nuevo León. México. 64347. "),
                                  TextSpan(
                                      text: "Aviso de Privacidad",
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           PDFScreen()),
                                          // );

                                          final Uri url = Uri.parse(
                                              'https://whistleblowwer.com/aviso-privacidad');
                                          if (!await launchUrl(url)) {
                                            print('Could not launch $url');
                                          }
                                        },
                                      style: const TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                ],
                                style: const TextStyle(
                                    fontFamily: 'Montserrat', fontSize: 13))),
                          ),
                        ],
                      ),
                    ),
                  )),
              Container(
                width: double.maxFinite,
                height: 96,
                padding: const EdgeInsets.only(top: 32),
                decoration: const BoxDecoration(color: Colors.white),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Icon(FeatherIcons.arrowLeft),
                        ),
                      ),
                    ),
                    const Text(
                      "Configuración",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.maxFinite,
                        height: 0.5,
                        color: ColorStyle.borderGrey,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
