import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:w_app/screens/signInUp/widgets/codeField_widget.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class SMSVerificationPage extends StatefulWidget {
  final String email;

  const SMSVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  State<SMSVerificationPage> createState() => _SMSVerificationPageState();
}

class _SMSVerificationPageState extends State<SMSVerificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final gradientStyle = GradientStyle();

  TextEditingController controllerPhone = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final focusNodePhone = FocusNode();
  final focusNodePassword = FocusNode();
  final _formKey = GlobalKey<FormState>();
  int _start = 180;
  Timer? _timer;

  int _resendTokenStart = 60; // Segundos para esperar antes de reenviar
  Timer? _resendTimer;
  bool _canResendCode = true; // Controla si el usuario puede reenviar el código

  //Input
  String _code = '';
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });

          Navigator.of(context).pop();
          showErrorSnackBar(context, "Expiró el OTP");
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void startResendTokenTimer() {
    _resendTokenStart = 60;
    _resendTimer = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        if (_resendTokenStart == 0) {
          setState(() {
            timer.cancel();
            _canResendCode = true; // Habilita el reenvío nuevamente
          });
        } else {
          setState(() {
            _resendTokenStart--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sizeV = MediaQuery.of(context).size.height / 100;
    double sizeH = MediaQuery.of(context).size.width / 100;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.logicalKey == LogicalKeyboardKey.backspace) {}
      },
      child: Scaffold(
          key: _scaffoldKey,
          body: SizedBox(
            width: sizeH * 100,
            height: sizeV * 100,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: Platform.isAndroid ? 36 : 66,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(right: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: ColorStyle.darkPurple,
                                      width: 1.5)),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 14,
                                color: ColorStyle.darkPurple,
                              ),
                            ),
                            const Text("Cambiar\nNúmero",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorStyle.darkPurple,
                                    fontFamily: "Montserrat")),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 56, bottom: 16),
                        width: 342,
                        child: const Text(
                          "Verifica tu mail",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const Text(
                        "El código vence en:",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: ColorStyle.midToneGrey,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 56),
                        width: 342,
                        child: Text(
                          "${_start ~/ 60}:${(_start % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Center(
                        child: CodeField(
                          focusNodes: _focusNodes,
                          controllers: _controllers,
                          onCodeChanged: (value) {
                            setState(() {
                              _code = value;
                            });
                          },
                          onCodeCompleted: () {
                            // Aquí se podría hacer alguna acción cuando se completa el código, como intentar iniciar sesión
                            print('Código ingresado: $_code');
                          },
                        ),
                      ),
                      PressTransform(
                        onPressed: () async {
                          if (_start > 0) {
                            bool responseValidate = await ApiService()
                                .validateOTP(_code, widget.email);
                            print("--");
                            print(responseValidate);

                            if (responseValidate == true) {
                              Navigator.of(_scaffoldKey.currentContext!)
                                  .pop(true);
                            } else {
                              if (mounted) {
                                showErrorSnackBar(context, "Código invalido");
                              }
                            }
                          } else {
                            showErrorSnackBar(context, "Expiró el OTP");
                          }
                        },
                        child: Container(
                          width: double.maxFinite,
                          height: 48,
                          margin: const EdgeInsets.only(top: 40),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: GradientStyle().whistleBlowwerGradient,
                          ),
                          child: const Text(
                            "Verificar",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Visibility(
                        visible:
                            _resendTokenStart > 0 && _resendTokenStart != 60,
                        child: Text(
                          _resendTokenStart > 0
                              ? "Volver a enviar en $_resendTokenStart"
                              : "Toca para reenviar",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (_canResendCode) {
                            // Comprueba si el usuario puede reenviar el código
                            final bool requestOTP =
                                await ApiService().requestOTP(widget.email);

                            if (requestOTP) {
                              if (mounted) {
                                showSuccessSnackBar(context,
                                    message:
                                        "Se ha enviado el código al correo");
                                startResendTokenTimer(); // Inicia el temporizador
                                _canResendCode =
                                    false; // Deshabilita el reenvío hasta que el temporizador termine
                              }
                            }
                          } else {
                            // Opcional: Mostrar un mensaje de error o una cuenta regresiva
                            showErrorSnackBar(context,
                                "Espera ${_resendTokenStart} segundos para reenviar el código");
                          }
                        },
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Reenviar código a ',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                  text: '${widget.email}',
                                  style: TextStyle(
                                      letterSpacing: 0.02 * 1,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(100, 31, 137, 1))),
                            ],
                          ),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
